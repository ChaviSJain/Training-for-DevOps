# Minimal Flask app with two routes.
from flask import Flask, jsonify

app = Flask(__name__)

@app.get("/")
def home():
    return jsonify(message="Hello from Flask on Lambda via API Gateway HTTP API!")


@app.get("/ping")
def ping():
    return {"pong": True}
