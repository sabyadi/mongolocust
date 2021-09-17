from bson.codec_options import TypeRegistry, CodecOptions
from faker import Faker
from locust import User, between

from decimal_codec import DecimalCodec
from settings import CLUSTER_URL, DB_NAME

import time
import pymongo
import os

# singleton Mongo client
MONGO_URI = os.environ.get('MONGO_URI')
if MONGO_URI:
    CLIENT = pymongo.MongoClient(MONGO_URI)
else:
    CLIENT = pymongo.MongoClient(CLUSTER_URL)


class MongoUser(User):
    """
    Base mongodb workload generator
    """
    # this class needs to be marked as abstract, otherwise locust will ry to instantiate it
    abstract = True

    # no think time between calls
    wait_time = between(0.0, 0.0)

    def __init__(self, environment):
        super().__init__(environment)
        self.db = CLIENT[DB_NAME]
        self.collection, self.collection_secondary = None, None
        self.faker = Faker()

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

    def ensure_collection(self, coll_name, indexes, read_preference=pymongo.read_preferences.Secondary()):
        """
        Define the collection and its indexes
        """
        # prepare a codec for decimal values
        decimal_codec = DecimalCodec()
        type_registry = TypeRegistry([decimal_codec])
        codec_options = CodecOptions(type_registry=type_registry)

        # create the collection if not exists
        if coll_name not in self.db.collection_names():
            collection = self.db.create_collection(
                coll_name, codec_options=codec_options)
        else:
            collection = self.db.get_collection(
                coll_name, codec_options=codec_options)

        # create the required indexes
        if indexes:
            collection.create_indexes(indexes)

        # also return the second collection with readPreference
        return collection, self.db.get_collection(coll_name, read_preference=read_preference)
