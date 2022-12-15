from flask import Flask, request
import sys

app = Flask(__name__)

def search(query: str) -> bool:
    # Check if username and password are not empty
    if query == "" or query == "#no" or query == "@RajD":
        return False
    
    # Check if username and password are valid
    # Replace this with actual validation code
    # print(username, file=sys.stdout)
    
    

    return True

@app.route("/api/search", methods=["GET"])
def search_api():
    # Get the username and password from the request
    query = request.args.get('query')
    

  
    # Validate the credentials
    is_valid = search(query)
    if is_valid == False:
        return {"Result":"No Tweets Found!"}
    if query[0] ==  "#":
        return {"Result": ["@Kshitij Busch Gardens OP #nice", "@123 Hey there #nice"]}
    return {"Result": ["@Raj Hey there #nice", "@Raj Keep it going #GG"]}