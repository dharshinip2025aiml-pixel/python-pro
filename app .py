
from flask_cors import CORS
from flask_bcrypt import Bcrypt
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from pymongo import MongoClient
from datetime import datetime, timedelta
import os
from dotenv import load_dotenv
from mood_detector import detect_text_mood, detect_face_mood
from recommender import recommend_movies

load_dotenv()

app = Flask(__name__)
CORS(app)
bcrypt = Bcrypt(app)

app.config["JWT_SECRET_KEY"] = os.getenv("JWT_SECRET_KEY", "super-secret-key-change-in-prod")
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = timedelta(hours=24)
jwt = JWTManager(app)

client = MongoClient(os.getenv("MONGO_URI", "mongodb://localhost:27017/"))
db = client["mood_movies"]
users_col = db["users"]
history_col = db["history"]


# ─── AUTH ───────────────────────────────────────────────────────────────────

@app.route("/register", methods=["POST"])
def register():
    data = request.json
    if users_col.find_one({"email": data["email"]}):
        return jsonify({"error": "Email already exists"}), 409
    hashed = bcrypt.generate_password_hash(data["password"]).decode("utf-8")
    user = {"name": data["name"], "email": data["email"], "password": hashed}
    result = users_col.insert_one(user)
    token = create_access_token(identity=str(result.inserted_id))
    return jsonify({"token": token, "name": data["name"]}), 201


@app.route("/login", methods=["POST"])
def login():
    data = request.json
    user = users_col.find_one({"email": data["email"]})
    if not user or not bcrypt.check_password_hash(user["password"], data["password"]):
        return jsonify({"error": "Invalid credentials"}), 401
    token = create_access_token(identity=str(user["_id"]))
    return jsonify({"token": token, "name": user["name"]}), 200


# ─── MOOD DETECTION ─────────────────────────────────────────────────────────

@app.route("/detect-text-mood", methods=["POST"])
@jwt_required()
def detect_text_mood_route():
    data = request.json
    text = data.get("text", "")
    if not text:
        return jsonify({"error": "No text provided"}), 400
    mood = detect_text_mood(text)
    return jsonify({"mood": mood})


@app.route("/detect-face-mood", methods=["POST"])
@jwt_required()
def detect_face_mood_route():
    data = request.json
    image_data = data.get("image", "")
    if not image_data:
        return jsonify({"error": "No image data provided"}), 400
    mood = detect_face_mood(image_data)
    return jsonify({"mood": mood})


# ─── RECOMMENDATIONS ────────────────────────────────────────────────────────

@app.route("/recommend-movies", methods=["POST"])
@jwt_required()
def recommend():
    user_id = get_jwt_identity()
    data = request.json
    mood = data.get("mood", "normal")
    movies = recommend_movies(mood)
    history_col.insert_one({
        "user_id": user_id,
        "mood": mood,
        "recommended_movies": movies,
        "timestamp": datetime.utcnow()
    })
    return jsonify({"mood": mood, "movies": movies})


# ─── HISTORY ────────────────────────────────────────────────────────────────

@app.route("/history", methods=["GET"])
@jwt_required()
def get_history():
    user_id = get_jwt_identity()
    records = list(history_col.find(
        {"user_id": user_id},
        {"_id": 0}
    ).sort("timestamp", -1).limit(20))
    for r in records:
        r["timestamp"] = r["timestamp"].isoformat()
    return jsonify({"history": records})


if __name__ == "__main__":
    app.run(debug=True, port=5000)
