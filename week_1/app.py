#imports Flask class from the Flask Library
#Flask is a lightweight python framework for building web applications
from flask import Flask

#Creates an instance of the flask app and lets flask know where to find the resources
app=Flask(__name__)

#decorater that maps the URL to the function
@app.route("/")
#function called,returns a plain string as a web response
def hello_world():
    return " Hello from Flask app inside Docker"

#ensures app runs only when called directly
if __name__=="__main__":
    #makes it accessible from outside the container(docker),port it listens on
    app.run(host="0.0.0.0",port=5000)