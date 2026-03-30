from flask import Flask, request, jsonify
from ollamafreeapi import OllamaFreeAPI
import time
import logging

# লগিং সেটআপ
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
    if not messages:
        return jsonify({"error": "messages field is required"}), 400

    model = data.get('model', 'llama3.2:3b')

    # চ্যাট হিস্ট্রি ফরম্যাট করা
    prompt = "\n".join([
        f"{m['role']}: {m['content']}"
        for m in messages
        if 'role' in m and 'content' in m
    ])

    logger.info(f"Request → model={model}, messages={len(messages)}")

    try:
        response_text = client.chat(model=model, prompt=prompt)

        prompt_tokens = len(prompt.split())
        completion_tokens = len(response_text.split())

        return jsonify({
            "id": f"chatcmpl-{int(time.time())}",
            "object": "chat.completion",
            "created": int(time.time()),
            "model": model,
            "choices": [{
                "index": 0,
                "message": {
                    "role": "assistant",
                    "content": response_text
                },
                "finish_reason": "stop"
            }],
            "usage": {
                "prompt_tokens": prompt_tokens,
                "completion_tokens": completion_tokens,
                "total_tokens": prompt_tokens + completion_tokens
            }
        })

    except Exception as e:
        logger.error(f"Error: {e}")
        return jsonify({
            "error": {
                "message": str(e),
                "type": "api_error",
                "code": 500
            }
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=7860, debug=False)
