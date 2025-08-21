# Import the Flask framework to create a web application
from flask import Flask

# Import the aws_wsgi response adapter to convert Flask responses into AWS Lambda-compatible format
from aws_wsgi import response

# Create a Flask application instance
app = Flask(__name__)

# Define a route for the root URL ("/") that returns a simple greeting
@app.route("/")
def hello():
    return "Hello from Lambda!"

# Define the Lambda handler function that AWS will invoke
# It takes the event and context from API Gateway and passes them to the Flask app via aws_wsgi
# event: Contains the incoming request data from API Gateway
# context: Contains metadata about the Lambda execution
# This line uses the aws-wsgi adapter to translate the Lambda event into a WSGI-compatible request that Flask understands.
# app: Flask application instance.
# response(...): Converts the Flask response back into a format that AWS Lambda/API Gateway expects
def handler(event, context):
    return response(app, event, context)
