from flask import Flask, request
import sys

app = Flask(__name__)

def reTweet(retweet: str) -> bool:
    # Check if username and password are not empty
    if retweet == "":
        return False

    # Check if username and password are valid
    # Replace this with actual validation code
    # print(username, file=sys.stdout)
    
    

    return True

@app.route("/api/retweet", methods=["POST"])
def reTweet_api():
    # Get the username and password from the request
    retweetStr = request.args.get('retweet')
    

  
    # Validate the credentials
    is_valid = reTweet(retweetStr)
    if is_valid == False:
        return {"Reponse":"Error ReTweeting!"}
    return {"Reponse": "ReTweet is Live!"}