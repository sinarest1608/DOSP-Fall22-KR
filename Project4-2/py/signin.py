from flask import Flask, request
import sys

app = Flask(__name__)

def validate_credentials(username: str, password: str) -> bool:
    # Check if username and password are not empty
    if username == "" or  password == "":
        return False

    # Check if username and password are valid
    # Replace this with actual validation code
    # print(username, file=sys.stdout)
    
    is_valid = (username == "myusername" and password == "mypassword")

    return is_valid

@app.route("/api/signin", methods=["POST"])
def validate_credentials_api():
    # Get the username and password from the request
    username = request.args.get('username')
    password = request.args.get('password')

  
    # Validate the credentials
    is_valid = validate_credentials(username, password)

    return {"logged_in": is_valid}