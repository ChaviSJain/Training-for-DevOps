from app import app
import serverless_wsgi #provided via the lambda layer
 
def lambda_handler(event,context):
    # Translate API Gateway HTTP API event -> WSGI -> Flask
    return serverless_wsgi.handle_request(app, event, context)
