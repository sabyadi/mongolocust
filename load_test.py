from settings import CLUSTER_URL, DB_NAME, COLLECTION_NAME
from locust import User, task, between
from faker import Faker
from bson.decimal128 import Decimal128
from decimal import Decimal
from bson.codec_options import TypeCodec, TypeRegistry, CodecOptions

import time
import pymongo
import random

# singleton Mongo client
CLIENT = pymongo.MongoClient(CLUSTER_URL)

# docs to insert per batch insert
DOCS_PER_BATCH = 100

# number of cache entries for queries
NAMES_TO_CACHE = 1000


class DecimalCodec(TypeCodec):
    python_type = Decimal  # the Python type acted upon by this type codec
    bson_type = Decimal128  # the BSON type acted upon by this type codec

    def transform_python(self, value):
        """
        Function that transforms a custom type value into a type
        that BSON can encode.
        """
        return Decimal128(value)

    def transform_bson(self, value):
        """
        Function that transforms a vanilla BSON type value into our
        custom type.
        """
        return value.to_decimal()


class MongoUser(User):
    """
    Sample mongodb workload generator
    """
    # no delays between operations
    wait_time = between(0.0, 0.0)

    def __init__(self, environment):
        super().__init__(environment)
        self.db = None
        self.collection, self.collection_secondary = None, None
        self.faker = Faker()
        self.name_cache = []

    def _process(self, name, func):
        """
        Run something in the locust context and time its execution
        :param name: operation name to be used in stats output
        :param func: what to run
        """
        start_time = time.time()
        try:
            func()
        except Exception as e:
            # output the error for debugging purposes
            print(e)
            total_time = int((time.time() - start_time) * 1000)
            self.environment.events.request_failure.fire(
                request_type='mongo', name=name, response_time=total_time, exception=e, response_length=0,
            )
        else:
            total_time = int((time.time() - start_time) * 1000)
            self.environment.events.request_success.fire(
                request_type='mongo', name=name, response_time=total_time, response_length=1
            )

    def ensure_collection(self, coll_name, indexes):
        """
        Define the collection and its indexes
        """
        # prepare a codec for decimal values
        decimal_codec = DecimalCodec()
        type_registry = TypeRegistry([decimal_codec])
        codec_options = CodecOptions(type_registry=type_registry)

        # create the collection if not exists
        if coll_name not in self.db.collection_names():
            collection = self.db.create_collection(coll_name, codec_options=codec_options)
        else:
            collection = self.db.get_collection(coll_name, codec_options=codec_options)

        # create the required indexes
        if indexes:
            collection.create_indexes(indexes)

        # also return the second collection with readPreference=SECONDARY for analytical queries
        return collection, self.db.get_collection(coll_name, read_preference=pymongo.read_preferences.Secondary())

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

    def run_aggregation_pipeline(self):
        """
        Run an aggregation pipeline on a analytical node
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
        self.db = CLIENT[DB_NAME]
        index1 = pymongo.IndexModel([('first_name', pymongo.ASCENDING), ("last_name", pymongo.DESCENDING)],
                                    name="idx_first_last")
        self.collection, self.collection_secondary = self.ensure_collection(COLLECTION_NAME, [index1])
        self.name_cache = []

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

    def find_document(self):
        # at least one insert needs to happen
        if not self.name_cache:
            return

        # find a random document using an index
        cached_names = random.choice(self.name_cache)
        self.collection.find_one({'first_name': cached_names[0], 'last_name': cached_names[1]})

    @task(weight=3)
    def do_find_document(self):
        self._process('find-document', self.find_document)

    @task(weight=1)
    def do_insert_document(self):
        self._process('insert-document', self.insert_single_document)

    @task(weight=1)
    def do_insert_document_bulk(self):
        self._process('insert-document-bulk', lambda: self.collection.insert_many(
            [self.generate_new_document() for _ in
             range(DOCS_PER_BATCH)], ordered=False))

    @task(weight=1)
    def do_run_aggregation_pipeline(self):
        self._process('run-aggregation-pipeline', self.run_aggregation_pipeline)
