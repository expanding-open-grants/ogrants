import csv
import json
from elasticsearch import Elasticsearch, helpers

# Function to convert a CSV to JSON
# Takes the file paths as arguments
def make_json(csvFilePath, jsonFilePath):

	# create a dictionary
	data = []

	# Open a csv reader called DictReader
	with open(csvFilePath, encoding='utf-8') as csvf:
		csvReader = csv.DictReader(csvf)

		# Convert each row into a dictionary
		# and add it to data
		for rows in csvReader:
			data.append(rows)

	# Open a json writer, and use the json.dumps()
	# function to dump data
	with open(jsonFilePath, 'w', encoding='utf-8') as jsonf:
		jsonf.write(json.dumps(data, indent=4))

def index(es,dataset,index="ogrants"):
	bulk_size = 500
	if not(es.indices.exists(index)):
		es.indices.create(index=index)
	for i in range(0, len(dataset), bulk_size):
		body = []
		for rec in dataset[i:i + bulk_size]:
			body.append({
				'index': {
					'_index': index,
                    '_id': rec['id']
					}
				})
			body.append(rec)
			es.bulk(body)
	if es.indices.exists("bkup_ogrants"):
		es.indices.delete("bkup_ogrants")
		self.stdout.write('dataset indexed')

# Driver Code

# Decide the two file paths according to your
# computer system
csvFilePath = r'ogrants.csv'
jsonFilePath = r'ogrants.json'

# Call the make_json function
make_json(csvFilePath, jsonFilePath)

data = {}
client = Elasticsearch("http://localhost:9200")
with open('ogrants.json') as f:
	data = json.load(f)
index(client,data)
