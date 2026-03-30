FROM python:3.10-slim

WORKDIR /app

# সিস্টেম ডিপেন্ডেন্সি ইনস্টল
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# requirements ফাইল কপি এবং লাইব্রেরি ইনস্টল
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# অ্যাপ্লিকেশন ফাইল কপি
COPY app.py .

# নিরাপত্তার জন্য Non-root user তৈরি
RUN useradd -m appuser
USER appuser

EXPOSE 7860

# Gunicorn কনফিগারেশন আপডেট: ১ জন ওয়ার্কার এবং লম্বা টাইমআউট
CMD ["gunicorn", "--bind", "0.0.0.0:7860", "--timeout", "120", "--workers", "1", "--threads", "2", "app:app"]
