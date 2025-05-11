import os
from flask import Flask, request, jsonify
from flask_cors import CORS
from pymongo import MongoClient
from dotenv import load_dotenv
from datetime import datetime

load_dotenv()

app = Flask(__name__)
CORS(app)

# MongoDB 연결
client = MongoClient(os.getenv("MONGODB_URI"))
db = client.get_database("schedules_db") # 새 데이터베이스 또는 기존 데이터베이스 사용
texts_collection = db.get_collection("user_texts") # 문자열을 저장할 새 컬렉션

@app.route('/')
def home():
    return "Flask 서버 실행 중"

# 웹에서 입력된 문자열을 MongoDB에 저장하는 API 엔드포인트
@app.route('/save-text', methods=['POST'])
def save_user_text():
    try:
        data = request.get_json()
        user_text_content = data.get('textContent') # Flutter에서 보낼 키 이름

        if not user_text_content:
            return jsonify({"message": "textContent is required"}), 400

        # 저장할 문서 생성
        text_document = {
            "content": user_text_content,
            "createdAt": datetime.utcnow() # UTC 기준 현재 시간 저장
        }

        result = texts_collection.insert_one(text_document)
        inserted_id = str(result.inserted_id)

        print(f"문자열 저장 성공: {user_text_content}, ID: {inserted_id}")
        return jsonify({"message": "Text saved successfully to MongoDB", "id": inserted_id}), 201

    except Exception as e:
        print(f"Error saving text to MongoDB: {e}")
        return jsonify({"message": "Failed to save text", "error": str(e)}), 500

# 저장된 문자열 조회 API
@app.route('/get-texts', methods=['GET'])
def get_user_texts():
    try:
        all_texts = []
        for doc in texts_collection.find().sort("createdAt", -1): # 최신순 정렬
            doc['_id'] = str(doc['_id'])
            all_texts.append(doc)
        return jsonify(all_texts), 200
    except Exception as e:
        print(f"Error fetching texts: {e}")
        return jsonify({"message": "Failed to fetch texts", "error": str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)