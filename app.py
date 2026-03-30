from flask import Flask, request, jsonify
from flask_cors import CORS  # নতুন যোগ করা হয়েছে
from ollamafreeapi import OllamaFreeAPI
import time

app = Flask(__name__)
CORS(app)  # এটি ব্রাউজার থেকে কানেক্ট করার অনুমতি দেবে

client = OllamaFreeAPI()

@app.route('/')
def home():
    return "API is running!"

@app.route('/v1/chat/completions', methods=['POST', 'OPTIONS'])
def chat():
    # ব্রাউজার অনেক সময় প্রথমে OPTIONS রিকোয়েস্ট পাঠায়, সেটি হ্যান্ডেল করা
    if request.method == 'OPTIONS':
        return '', 204

    data = request.json
    messages = data.get('messages', [])
    model = data.get('model', 'llama3.2:3b')

    prompt = "\n".join([f"{m['role']}: {m['content']}" for m in messages])

    try:
        response_text = client.chat(model=model, prompt=prompt)
        return jsonify({
            "id": f"chatcmpl-{int(time.time())}",
            "object": "chat.completion",
            "created": int(time.time()),
            "model": model,
            "choices": [{
                "index": 0,
                "message": {"role": "assistant", "content": response_text},
                "finish_reason": "stop"
            }]
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=7860)
