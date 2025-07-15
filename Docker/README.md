
# Simple HTTP Server with Docker

This project is a **simple HTTP server** written in Python using **Flask**.  
It provides a single API endpoint: `/api/v1/status` on **port 8000**.

---

## 🚀 Features

- **GET /api/v1/status**  
Returns:  
```json
{ "status": "OK" }
```

- **POST /api/v1/status**  
Accepts JSON body like:  
```json
{ "status": "not OK" }
```
Returns the same body with HTTP status code **201**.  
Subsequent **GET** requests will return the latest status.

---

## 🐳 How to Run (on Linux)

### 1️⃣ Download the files

Download these three files from the repository to your local machine:

- `app.py`
- `requirements.txt`
- `Dockerfile`

### 2️⃣ Create and enter the project folder

Open a terminal and run:

```bash
mkdir simple-http-server
cd simple-http-server
```

### 3️⃣ Move the downloaded files into this folder

Make sure the files `app.py`, `requirements.txt`, and `Dockerfile` are inside the `simple-http-server` directory.

### 4️⃣ Build Docker Image
```bash
sudo docker build -t simple-http-server .
```

---

### 5️⃣ Run the Docker Container
```bash
sudo docker run -d -p 8000:8000 --name myserver simple-http-server
```

---

## 🔍 Test the Server

### ✅ Test GET Request
```bash
curl http://localhost:8000/api/v1/status
```
Expected output:
```json
{ "status": "OK" }
```

---

### ✅ Test POST Request
```bash
curl -X POST -H "Content-Type: application/json" \
-d '{"status": "not OK"}' \
http://localhost:8000/api/v1/status
```
Expected output:
```json
{ "status": "not OK" }
```

---

### ✅ Test GET Again
```bash
curl http://localhost:8000/api/v1/status
```
Expected output:
```json
{ "status": "not OK" }
```

---

## 📂 Project Structure
```
Docker/
├── app.py
├── requirements.txt
├── Dockerfile
└── README.md
```

---

## 📄 Files Description

### `app.py`
The HTTP server implementation with Flask.

### `requirements.txt`
Contains:  
```
flask
```

### `Dockerfile`
Builds the image based on `python:3.12-slim`, installs Flask, and exposes port **8000**.

---

## 🛑 Useful Docker Commands

Stop the container:
```bash
sudo docker stop myserver
```

Check logs:
```bash
sudo docker logs myserver
```

Remove the container:
```bash
sudo docker rm myserver
```

List running containers:
```bash
sudo docker ps
```

---

## 📌 Requirements (already installed on your Linux)
- Docker Engine (`docker.io`)
- Python is inside the Docker image; no need to install on your machine.

---

## 📝 Notes
If you want to run `docker` without `sudo`, add your user to the Docker group:
```bash
sudo usermod -aG docker $USER
```
Then log out and log back in.

---

## ✨ Done!
Now anyone can run this project easily on any Linux machine using Docker.
