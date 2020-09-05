FROM tiangolo/uwsgi-nginx-flask:python3.8-alpine

WORKDIR /app

COPY requirements.txt .
RUN pip3 install --upgrade pip
RUN pip3 install -r requirements.txt

COPY api.py .
COPY mongo.py .
COPY entrypoint.sh .
COPY templates/ templates/

EXPOSE 5000
RUN chmod u+x entrypoint.sh
ENTRYPOINT [ "./entrypoint.sh" ]

# setup nginx
# keepalivd