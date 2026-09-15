#!/usr/bin/env python3
"""
AWS Lambda Function Example: Hello World
This function demonstrates basic Lambda concepts for interview preparation.
"""

import json
import logging
import os

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Main Lambda handler function
    
    Args:
        event (dict): Event data passed to the function
        context (object): Runtime information from AWS Lambda
    
    Returns:
        dict: Response with status code and body
    """
    logger.info(f"Received event: {json.dumps(event)}")
    
    # Extract information from event
    http_method = event.get('httpMethod', 'UNKNOWN')
    path = event.get('path', '/')
    
    # Get environment variables
    function_name = os.environ.get('AWS_LAMBDA_FUNCTION_NAME', 'unknown')
    function_version = os.environ.get('AWS_LAMBDA_FUNCTION_VERSION', '$LATEST')
    
    # Prepare response body
    response_body = {
        'message': 'Hello from AWS Lambda!',
        'function': {
            'name': function_name,
            'version': function_version
        },
        'request': {
            'method': http_method,
            'path': path
        },
        'timestamp': context.aws_request_id if hasattr(context, 'aws_request_id') else 'unknown'
    }
    
    # Add query parameters if present
    if 'queryStringParameters' in event and event['queryStringParameters']:
        response_body['query_parameters'] = event['queryStringParameters']
    
    # Return successful response
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(response_body)
    }

# For local testing
if __name__ == "__main__":
    # Test event
    test_event = {
        'httpMethod': 'GET',
        'path': '/hello',
        'queryStringParameters': {
            'name': 'world',
            'test': 'true'
        }
    }
    
    # Mock context
    class MockContext:
        def __init__(self):
            self.aws_request_id = 'test-request-id-123'
    
    result = lambda_handler(test_event, MockContext())
    print(json.dumps(result, indent=2))