#!/usr/bin/python
import boto3, sys
client = boto3.client('s3', aws_access_key_id=sys.argv[3], aws_secret_access_key=sys.argv[4])
client.download_file(sys.argv[1],sys.argv[2],sys.argv[5])
