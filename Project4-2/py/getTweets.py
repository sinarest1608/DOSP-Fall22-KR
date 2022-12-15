from flask import Flask, request
import sys

app = Flask(__name__)

def getTweets(username: str) -> bool:
    # Check if username and password are not empty
    if username == "":
        return False

    # Check if username and password are valid
    # Replace this with actual validation code
    # print(username, file=sys.stdout)
    
    

    return True

@app.route("/api/getTweets", methods=["POST"])
def get_tweets_api():
    # Get the username and password from the request
    username = request.args.get('username')
    

  
    # Validate the credentials
    is_valid = getTweets(username)
    if is_valid == False:
        return {"Tweets":["No Tweets Found!"]}
    return {"Tweets": ["@123 Hey there #nice", "@Raj Keep it going #GG"]}