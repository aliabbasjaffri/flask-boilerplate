#!/bin/sh
set -e

# gunicorn --bind=0.0.0.0:5001 --threads=25 --workers=2 api:app
gunicorn --bind unix:api.sock --threads=25 --workers=2 api:app