# !/bin/bash

apt update && apt upgrade -yq
apt install -yq python3 python3-pip nginx
python3 -m pip install --upgrade pip
python3 -m pip install -r requirements.txt
cd ..
cp -R flask-boilerplate /opt/api/
rm -rf flask-boilerplate
chown -R <USER-NAME>:<USER-NAME> /opt/api
chmod -R g+w /opt/api
mv /opt/api/api.service /etc/systemd/system/
systemctl daemon-reload
systemctl start api.service
systemctl enable api.service
systemctl status api.service
cp /opt/api/nginx.conf /etc/nginx/sites-available/api
ln -s /etc/nginx/sites-available/api /etc/nginx/sites-enabled
nginx -t
systemctl restart nginx
systemctl status nginx
sudo ufw allow 'Nginx Full'