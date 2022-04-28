from locust import between

from mongo_user import MongoUser, mongodb_task
from settings import DEFAULTS

import pymongo
import random

# number of cache entries for queries
NAMES_TO_CACHE = 1000


class MongoSampleUser(MongoUser):
    """
    Generic sample mongodb workload generator
    """
    # no delays between operations
    wait_time = between(0.0, 0.0)

    def __init__(self, environment):
        super().__init__(environment)
        self.name_cache = []

    def generate_new_document(self):
        """
        Generate a new sample document
        """
        document = {
            'first_name': self.faker.first_name(),
            'last_name': self.faker.last_name(),
            'address': self.faker.street_address(),
            'city': self.faker.city(),
            'total_assets': self.faker.pydecimal(min_value=100, max_value=1000, right_digits=2)
        }
        return document

    @mongodb_task(weight=int(DEFAULTS['AGG_PIPE_WEIGHT']))
    def run_aggregation_pipeline(self):
        """
        Run an aggregation pipeline on a secondary node
        """
        # count number of inhabitants per city
        group_by = {
            '$group': {
                '_id': '$city',
                'total_inhabitants': {'$sum': 1}
            }
        }

        # rename the _id to city
        set_columns = {'$set': {'city': '$_id'}}
        unset_columns = {'$unset': ['_id']}

        # sort by the number of inhabitants desc
        order_by = {'$sort': {'total_inhabitants': pymongo.DESCENDING}}

        pipeline = [group_by, set_columns, unset_columns, order_by]

        # make sure we fetch everything by explicitly casting to list
        # use self.collection instead of self.collection_secondary to run the pipeline on the primary
        return list(self.collection_secondary.aggregate(pipeline))

    def on_start(self):
        """
        Executed every time a new test is started - place init code here
        """
        # prepare the collection
        index1 = pymongo.IndexModel([('first_name', pymongo.ASCENDING), ("last_name", pymongo.DESCENDING)],
                                    name="idx_first_last")
        self.collection, self.collection_secondary = self.ensure_collection(DEFAULTS['COLLECTION_NAME'], [index1])
        self.name_cache = []

    @mongodb_task(weight=int(DEFAULTS['INSERT_WEIGHT']))
    def insert_single_document(self):
        document = self.generate_new_document()

        # cache the first_name, last_name tuple for queries
        cached_names = (document['first_name'], document['last_name'])
        if len(self.name_cache) < NAMES_TO_CACHE:
            self.name_cache.append(cached_names)
        else:
            if random.randint(0, 9) == 0:
                self.name_cache[random.randint(0, len(self.name_cache) - 1)] = cached_names

        self.collection.insert_one(document)

    @mongodb_task(weight=int(DEFAULTS['FIND_WEIGHT']))
    def find_document(self):
        # at least one insert needs to happen
        if not self.name_cache:
            return

        # find a random document using an index
        cached_names = random.choice(self.name_cache)
        self.collection.find_one({'first_name': cached_names[0], 'last_name': cached_names[1]})

    @mongodb_task(weight=int(DEFAULTS['BULK_INSERT_WEIGHT']), batch_size=int(DEFAULTS['DOCS_PER_BATCH']))
    def insert_documents_bulk(self):
        self.collection.insert_many(
            [self.generate_new_document() for _ in
             range(int(DEFAULTS['DOCS_PER_BATCH']))])
