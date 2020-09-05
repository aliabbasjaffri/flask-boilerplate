import os
from pymongo import MongoClient

class MongoAPI:
    def __init__(self):
        self.client = MongoClient(
            'mongodb://{}:27017/'.format(os.environ['DB_CONNECTION']),
            username='{}'.format(os.environ['MONGO_USERNAME']),
            password='{}'.format(os.environ['MONGO_PASSWORD']))

        database = '{}'.format(os.environ['MONGO_DB_NAME'])
        collection = '{}-collection'.format(os.environ['MONGO_DB_NAME'])
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
        output = []
        if None in items or {} in items:
            return output
        
        for item in items:
            print(item)
            output.append({item: item})
        return output

    def update(self, data, id):
        response = self.collection.update_one({'_id': id}, {'$set': data})
        return {
            'Status': 'Item updated successfully' if response.modified_count > 0 else 'Item update unsuccessful'
            }
    
    def delete(self, id):
        response = self.collection.delete_one({'_id': id})
        return {'Status': 'Item deleted successfully' if response.deleted_count > 0 else 'Item not found.'}