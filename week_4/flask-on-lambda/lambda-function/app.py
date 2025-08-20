from flask import Flask
from aws_wsgi import response

app = Flask(__name__)

@app.route("/")
def hello_world():
    return "Hello from Flask app inside Lambda!"

def handler(event, context):
    return response(app, event, context)
