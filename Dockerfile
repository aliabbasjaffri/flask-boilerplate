FROM python:3-slim

RUN mkdir -p /opt/api
WORKDIR /opt/api

COPY requirements.txt .
RUN pip3 install --upgrade pip
RUN pip3 install -r requirements.txt

COPY api.py .
COPY mongo.py .
COPY templates/ templates/
EXPOSE 5000
ENTRYPOINT ["gunicorn" , "--bind=api:5000", "--threads=25", "--workers=2", "api:app"]
