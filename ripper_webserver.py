from flask import Flask, request, send_from_directory
import subprocess
import os


app = Flask(__name__)

@app.route("/") #this can be changed to affect the url but regular / for root (in this case just localhost)
def serve_index():                          #static directory needs to be created in working dir that webserver is in. This is a magic dir that works with flask
    return send_from_directory("static", "ripper_frontend.html") #This says go into dir static, find file ripper_frontend.html and send as an HTTP response
                               #to go deeper, it could be static/anotherdirectory/thenanotherone/ripper_frontend.html
                               #I got a 404 because I never moved ripper fronend into the static dir. As soon as I did that it worked. 


@app.route("/maclookup", methods=["POST"]) #html form URL MUST MATCH THIS URL 
def mac_lookup():
    macs = request.form["mac_input"]  #This pulling the POST from the front end and placing into a python var named "macs"
    
    script_path = os.path.join(os.path.dirname(__file__), "web_mac_ripper.sh") #This REPLACED line 23 A FANTASTIC LINE ! No matter which machine you're on, it knows the path of the script as long as the script is in the same dir as the python webserver. I made this for GIT pulldowns
    
    result = subprocess.run(
        
        #["/home/josec/projects/Mac-Attack/web_mac_ripper.sh"],  #full path of the script. ./script would work if in the same dir. 
        #["/home/josec/projects/scripts/test.sh"], this was a test
        [script_path],   #referencing the new var line 19
        input=macs,
        text=True,
        capture_output=True
    )
#    return f"<pre>{result.stdout}</pre>"
    return f"""
<pre style="font-family:monospace; background-color:#f4f4f4; padding:10px; border-radius:5px; font-size:24px; white-space:pre-wrap;">
{result.stdout}
</pre>
"""

#This is for my future about page for a quick explanation. I may build dynamic routing if I need more pages but idk if I want to get crazy.
#@app.route("/about")
#def serve_about():
#    return send_from_directory("static", "about.html")  #--send_from_directory is a built in flask function that is as readable as can be.  


if __name__ == "__main__":  #Basically means "if you run this directly" an example of indirectly would be running it as a module
    # Configuration from environment or defaults
    host = os.environ.get("FLASK_RUN_HOST", "10.0.0.62") # I can set this to the ip address of the device hosting the webserver on the LAN if I want. 
    port = int(os.environ.get("FLASK_RUN_PORT", 5000))
    ssl_cert = os.environ.get("SSL_CERT_FILE")
    ssl_key  = os.environ.get("SSL_KEY_FILE")

    if ssl_cert and ssl_key:
        # HTTPS mode
        app.run(host=host, port=port, ssl_context=(ssl_cert, ssl_key)) #test with a curl using a self signed cert ---still need to do this
    else:
        # HTTP mode
        app.run(host=host, port=port, debug=True)


#to set the port and IP I can do this in terminal 
#export FLASK_RUN_HOST=0.0.0.0 # but I should use localhost 
#export FLASK_RUN_PORT=8080 
#export SSL_CERT_FILE=/path/to/cert.pem -----still need to create these
#export SSL_KEY_FILE=/path/to/key.pem
