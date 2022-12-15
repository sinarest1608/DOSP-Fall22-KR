from flask import Flask, request
import sys

app = Flask(__name__)

def tweet(tweet: str) -> bool:
    # Check if username and password are not empty
    if tweet == "":
        return False

    # Check if username and password are valid
    # Replace this with actual validation code
    # print(username, file=sys.stdout)
    
    

    return True

@app.route("/api/tweet", methods=["POST"])
def tweet_api():
    # Get the username and password from the request
    tweetStr = request.args.get('tweet')
    

  
    # Validate the credentials
    is_valid = tweet(tweetStr)
    if is_valid == False:
        return {"Reponse":"Error Tweeting!"}
    return {"Reponse": "Tweet is Live!"}