from flask import Flask, request, jsonify

app = Flask(__name__)
status = "OK"

@app.route("/api/v1/status", methods=["GET", "POST"])
def status_api():
    global status
    if request.method == "GET":
        return jsonify({"status": status}), 200
    elif request.method == "POST":
        data = request.get_json()
        status = data.get("status", "OK")
        return jsonify({"status": status}), 201

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
