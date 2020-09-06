#!/bin/sh
set -e

# gunicorn --bind=0.0.0.0:5000 --threads=25 --workers=2 api:app
gunicorn --bind unix:/opt/api/app.sock --threads=25 --workers=2 -m 007 api:app