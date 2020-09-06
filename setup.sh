# !/bin/bash

apt update && apt upgrade -yq
apt install -yq python3 python3-pip nginx
python3 -m pip install --upgrade pip
python3 -m pip install -r requirements.txt
