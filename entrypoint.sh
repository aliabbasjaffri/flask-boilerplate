#!/bin/sh

if [ "${ENV}" = "devl" ]
then
    /usr/local/bin/gunicorn --bind=0.0.0.0:5000 --threads=25 --workers=2 api:app
    echo "[INFO] Gunicorn started"
fi

if [ "${ENV}" = "prod" ]
then
    /usr/local/bin/gunicorn --bind unix:/opt/api/app.sock --threads=25 --workers=2 -m 007 api:app
    echo "[INFO] Gunicorn started"
fi

exec "$@"