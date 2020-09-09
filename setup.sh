# !/bin/bash

apt update && apt upgrade -yq
apt install -yq python3 python3-pip nginx
python3 -m pip install --upgrade pip
python3 -m pip install -r requirements.txt
cd ..
mv flask-boilerplate /opt/api/
chown -R www-data:www-data /opt/api
chmod -R g+w /opt/api
mv /opt/api/api.service /etc/systemd/system/
systemctl daemon-reload
systemctl start api.service
systemctl enable api.service
systemctl status api.service
mv /opt/api/nginx.conf /etc/nginx/sites-available/api
ln -s /etc/nginx/sites-available/api /etc/nginx/sites-enabled
nginx -t
systemctl restart nginx
systemctl status nginx
sudo ufw allow 'Nginx Full'