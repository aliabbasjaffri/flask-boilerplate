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
openssl req -new -nodes -text -out flask.root.csr           \
  -keyout flask.root.key -subj "/CN=<YOUR-DOMAIN>"
# Changing permissions on root certificate key
chmod og-rwx flask.root.key

# Generating root certificate with 10 years validity
openssl x509 -req -in flask.root.csr -text -days 3650       \
  -extfile /etc/ssl/openssl.cnf -extensions v3_ca           \
  -signkey flask.root.key -out flask.root.crt

# Copying root certificate as root.ca.crt in ssl store
cp flask.root.crt /etc/ssl/root.ca.crt

# Generating CSR for flask server certificate
openssl req -new -nodes -text -out flask.server.csr         \
  -keyout flask.server.key -subj "/CN=<YOUR-DOMAIN>"

# Changing certificate key access
chmod og-rwx flask.server.key

# Generating x509 certificate with 365 days validity
openssl x509 -req -in flask.server.csr -text -days 365      \
  -CA flask.root.crt -CAkey flask.root.key -CAcreateserial  \
  -out flask.server.crt

# Copying flask.server.* certificate key pair to 
# nginx certificate store
cp flask.server.{key,crt} /etc/ssl/

nginx -t
systemctl restart nginx
systemctl status nginx
sudo ufw allow 'Nginx Full'