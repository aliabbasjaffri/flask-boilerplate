# FROM tiangolo/uwsgi-nginx-flask:python3.8-alpine
FROM python:3-slim

RUN mkdir -p /opt/api
WORKDIR /opt/api

COPY requirements.txt .
RUN pip3 install --upgrade pip
RUN pip3 install -r requirements.txt

COPY api.py .
COPY mongo.py .
COPY entrypoint.sh .
COPY templates/ templates/

# setting env variable as devl incase it is not set
RUN if [ -z "$ENV" ]; then       \
        ENV="devl"               \
    fi

# if value is devl, then expose port 5000
RUN if [ "$ENV" = "devl" ]; then \
     EXPOSE 5000                 \
    fi

# ENTRYPOINT ["gunicorn" , "--bind=0.0.0.0:5000", "--threads=25", "--workers=2", "api:app"]
# ENTRYPOINT ["gunicorn", "--bind unix:/opt/api/app.sock", "--threads=25", "--workers=2", "-m 007", "api:app"]
RUN chmod u+x entrypoint.sh
ENTRYPOINT [ "./entrypoint.sh" ]