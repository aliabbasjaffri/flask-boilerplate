import os
from pathlib import Path
from dotenv import load_dotenv
from pymongo import MongoClient
from bson.json_util import dumps

env_path = Path('.') / '.env'
load_dotenv(dotenv_path=env_path)

db_connection = os.environ.get('DB_CONNECTION')
mongo_username = os.environ.get('MONGODB_USER')
mongo_password = os.environ.get('MONGODB_PASS')
mongo_database = os.environ.get('MONGO_DB_NAME')


class MongoAPI:
    def __init__(self):
        self.client = MongoClient(
            'mongodb://{}:27017/'.format(db_connection),
            username='{}'.format(mongo_username),
            password='{}'.format(mongo_password))

        database = '{}'.format(mongo_database)
        collection = '{}-collection'.format(mongo_database)
        cursor = self.client[database]
        self.collection = cursor[collection]

    def insert(self, data):
        response = self.collection.insert_one(data)
        return {
            'Status': 'Item Created Successfully',
            '_id': str(response.inserted_id)
            }

    def read_all_items(self):
        items = self.collection.find()
        output = {}
        for item in items:
            if "item" not in output:
                output["item"] = dumps(item)
            else:
                output["item"].append(dumps(item))
        return output

    def update(self, data, id):
        response = self.collection.update_one({'_id': id}, {'$set': data})
        if response.modified_count > 0:
            return {'Status': 'Item updated successfully'}
        else:
            return {'Status': 'Item update unsuccessful'}

    def delete(self, id):
        response = self.collection.delete_one({'_id': id})
        if response.deleted_count > 0:
            return {'Status': 'Item deleted successfully'}
        else:
            return {'Status': 'Item not found.'}
