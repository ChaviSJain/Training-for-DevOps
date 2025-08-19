#lambda_handler → This is the entry point AWS Lambda will call(event → contains data passed into the Lambda,context → contains metadata about the Lambda execution)
def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": "Hello from my first Terraform Lambda!"
    }
