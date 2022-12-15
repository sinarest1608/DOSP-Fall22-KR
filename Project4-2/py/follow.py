from flask import Flask, request
import sys

app = Flask(__name__)

def follow(currentUser: str, followUser: str) -> bool:
    # Check if username and password are not empty
    if currentUser == "" or followUser == "" or followUser == "RajdevD":
        return False

    # Check if username and password are valid
    # Replace this with actual validation code
    # print(username, file=sys.stdout)
    
    

    return True

@app.route("/api/follow", methods=["POST"])
def follow_api():
    # Get the username and password from the request
    currentUser = request.args.get('currentUser')
    followUser = request.args.get('followUser')
    

  
    # Validate the credentials
    is_valid = follow(currentUser, followUser)
    if is_valid == False:
        return {"Response":"User not Found"}
    return {"Response": "User followed!"}