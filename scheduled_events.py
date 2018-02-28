#!/usr/bin/python3

import os
import datetime
import json
from urllib.request import urlopen, Request
import socket
import sys
from time import sleep
from azure.storage import CloudStorageAccount

class BlobLogger():
	def __init__(self, account_name, account_key, container_name, blob_name=None):
		self.account_name = account_name
		self.account_key = account_key
		self.container_name = container_name
		self.storage_client = CloudStorageAccount(account_name, account_key)
		self.blob_service = self.storage_client.create_append_blob_service()
		if not blob_name:
			self.blob_name = socket.gethostname() + ".txt" # + "-" + datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S") + ".txt"
		else:
			self.blob_name = blob_name

		self.blob_service.create_container(container_name)
		if not self.blob_service.exists(self.container_name, self.blob_name):
			self.blob_service.create_blob(self.container_name, self.blob_name)

	def write(self, text):
		now = datetime.datetime.now().strftime("[%Y-%m-%d %H:%M:%S] ")
		self.blob_service.append_block(self.container_name, self.blob_name, str.encode(now + text + "\n"))
		print(now + text)


class EventsListener():
	def __init__(self, logger, sleep_delay=60, host="169.254.169.254"):
		self.logger = logger
		self.sleep_delay = sleep_delay
		self.metadata_url = "http://" + host + "/metadata/scheduledevents?api-version=2017-08-01"
		self.latest_data = ""

	def get_scheduled_events(self):
		try:
			req = Request(self.metadata_url)
			req.add_header('Metadata', 'true')
			resp = urlopen(req)
			data = json.loads(resp.read().decode())
			return data
		except Exception as ex:
			self.logger.write("Error while requesting Metadata service: " + str(ex))
			return None

	def handle_scheduled_events(self, data):
		sdata = str(data)
		print("Received data " + sdata)
		if sdata != self.latest_data:
			self.logger.write(sdata)
			self.latest_data = sdata

	def run_loop(self):
		self.logger.write("Started...")
		while True:
			data = self.get_scheduled_events()
			if data:
				self.handle_scheduled_events(data)
			sleep(self.sleep_delay)

def main():
	storage_account_key = os.getenv("STORAGE_ACCOUNT_KEY")
	storage_account_name = os.getenv("STORAGE_ACCOUNT_NAME")
	logger = BlobLogger(
			storage_account_name, 
			storage_account_key,
			"scheduledeventslogs"
			)

	listener = EventsListener(logger)
	listener.run_loop()

if __name__ == '__main__':
	main()
	sys.exit(0)