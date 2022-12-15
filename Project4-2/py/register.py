from flask import Flask, request
import sys

app = Flask(__name__)

def register(username: str, password: str, displayName: str) -> bool:
    # Check if username and password are not empty
    if username == "" or  password == "" or displayName == "":
        return False

    # Check if username and password are valid
    # Replace this with actual validation code
    # print(username, file=sys.stdout)
    
    

    return True

@app.route("/api/register", methods=["POST"])
def register_api():
    # Get the username and password from the request
    username = request.args.get('username')
    password = request.args.get('password')
    displayName = request.args.get('displayName')

  
    # Validate the credentials
    is_valid = register(username, password, displayName)

    return {"registered": is_valid}