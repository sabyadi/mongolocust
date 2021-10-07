import os

DEFAULTS = {'DB_NAME': 'sample',
            'COLLECTION_NAME': 'documents',
            'CLUSTER_URL': f'mongodb+srv://user:password@something.mongodb.net/sample?retryWrites=true&w=majority',
            'DOCS_PER_BATCH': 100,
            'INSERT_WEIGHT': 1,
            'FIND_WEIGHT': 3,
            'BULK_INSERT_WEIGHT': 1,
            'AGG_PIPE_WEIGHT': 1}


def init_defaults_from_env():
    for key in DEFAULTS.keys():
        value = os.environ.get(key)
        if value:
            DEFAULTS[key] = value


# get the settings from the environment variables
init_defaults_from_env()
