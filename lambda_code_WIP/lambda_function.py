import boto3
import json
import os

s3 = boto3.client("s3")

BUCKET = "codec4f26c862a321ef5"
KEY = "flag.txt"

def lambda_handler(event, context):
    try:
        obj = s3.get_object(
            Bucket=BUCKET,
            Key=KEY
        )

        flag = obj["Body"].read().decode("utf-8")

        return {
            "statusCode": 200,
            "body": json.dumps({
                "flag": flag
            })
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({
                "error": str(e)
            })
        }