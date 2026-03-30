from flask import Flask, request, jsonify
from ollamafreeapi import OllamaFreeAPI
import time
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
client = OllamaFreeAPI()

@app.route('/')
def home():
    return "Ollama Free API Bridge is running!"

@app.route('/health')
def health():
    return jsonify({"status": "ok", "timestamp": int(time.time())})

@app.route('/v1/chat/completions', methods=['POST'])
def chat():
    data = request.json
    if not data:
        return jsonify({"error": "No JSON body provided"}), 400

    messages = data.get('messages', [])
    model = data.get('model', 'llama3.2:3b')

    prompt = "\n".join([f"{m['role']}: {m['content']}" for m in messages if 'role' in m and 'content' in m])

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
