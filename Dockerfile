FROM python:3.10-slim

WORKDIR /app

# শুধু দরকার হলে build-essential রাখুন
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# আগে requirements কপি করুন (Docker cache সুবিধা)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# তারপর বাকি ফাইল কপি
COPY app.py .

# Non-root user তৈরি
RUN useradd -m appuser
USER appuser

EXPOSE 7860
CMD ["gunicorn", "--bind", "0.0.0.0:7860", "--timeout", "120", "--workers", "2", "app:app"]
```

**`requirements.txt`:**
```
flask
gunicorn
ollamafreeapi
```

**`.dockerignore`:**
```
__pycache__/
*.pyc
*.pyo
.env
*.md
