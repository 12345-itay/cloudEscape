import boto3
import json

def lambda_handler(event, context):
    # boto3 automatically uses the Lambda Execution Role credentials
    s3_client = boto3.client('s3')
    
    bucket_name = event.get('bucket_name')
    object_key = event.get('object_key')
    
    try:
        # Request originates from inside the VPC
        response = s3_client.get_object(Bucket=bucket_name, Key=object_key)
        content = response['Body'].read().decode('utf-8')
        
        return {
            'statusCode': 200,
            'body': json.dumps({'content': content})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }