# Sample Flask Application Boilerplate

## Setting up Flask Application for Development Environment
- The development environment is managed by Docker and docker-compose file
- Update the variables in `docker-compose` file and run `docker-compose up`


## Setting up Flask Application for Production Environment
- Launch a VM and checkout this repository in it.
- Move the project file to the appropriate directory
```bash
mv flask-boilerplate/ /opt/api
```
- Move the daemon service to the `systemd` path
```bash
mv /opt/api/api.service /etc/systemd/system/
```
- You can use the already created user `www-data` in the system. Alternatively you can create a new user as well.
- The advantage of user `www-data` is that you don't have to replace your user in `/etc/nginx/nginx.conf` file
```bash
# If you need to create a new user
useradd --system --user-group <USER-NAME>
chown -R <USER-NAME>:<USER-NAME> /opt/api
```
- Provide permissions to the api
```bash
chmod -R g+w /opt/api
```
- Reload the daemon and start it
```bash
systemctl daemon-reload
systemctl start api.service
systemctl enable api.service
systemctl status api.service
```
- If the command `systemctl status api.service` gives an error, run `journalctl -xe` for more details
- Next, setup nginx service to talk to gunicorn. Copy the contexts of `nginx.conf` in the folder to `/etc/nginx/sites-available/api` and replace the `<IP-ADDRESS>` with your server's IP address or your domain
- Execute the following steps:
```bash
# To verify if everything is okay
cat /etc/nginx/sites-available/api

# creating a link from sited available to sites enabled
ln -s /etc/nginx/sites-available/api /etc/nginx/sites-enabled

# testing the service for the updated configuration
nginx -t
systemctl restart nginx && systemctl status nginx
```
- In case there is any error you can try either of the following commands to check where the issue exists
```bash
journalctl -xe
---

journalctl -u api
---

journalctl -u nginx
---

tail -30 /var/logs/nginx/error.log
```
- Allowing the system `ufw` to enable information exchange on all Nginx ports
```bash
sudo ufw allow 'Nginx Full'
```
- You can check the `netstat` if the application is responding on a respective port
```bash
netstat -lpn | grep app
```

### Setup NGINX with SSL and HTTP/2
- Generate self-signed certificates using OpenSSL. Create a Certification Authourity root certificate and generate server certificate from that CA.
- This example is with self-signed root CA authrourity. If you have a root CA for your domain, skip the step for its generation and jump directly to generating `Flask Server CSR` and following steps.
```bash
# Generating root certificate `certificate signing request` to be used as Certification Authourity
openssl req -new -nodes -text -out flask.root.csr \
  -keyout flask.root.key -subj "/CN=<YOUR-DOMAIN>"
# Changing permissions on root certificate key
chmod og-rwx flask.root.key

# Generating root certificate with 10 years validity
openssl x509 -req -in flask.root.csr -text -days 3650 \
  -extfile /etc/ssl/openssl.cnf -extensions v3_ca \
  -signkey flask.root.key -out flask.root.crt

# Copying root certificate as root.ca.crt in ssl store
cp flask.root.crt /etc/ssl/root.ca.crt

# Generating CSR for flask server certificate
openssl req -new -nodes -text -out flask.server.csr \
  -keyout flask.server.key -subj "/CN=<YOUR-DOMAIN>"

# Changing certificate key access
chmod og-rwx flask.server.key

# Generating x509 certificate with 365 days validity
openssl x509 -req -in flask.server.csr -text -days 365 \
  -CA flask.root.crt -CAkey flask.root.key -CAcreateserial \
  -out flask.server.crt

# Copying flask.server.* certificate key pair to nginx certificate store
cp flask.server.{key,crt} /etc/ssl/
```
- The nginx conf file is already pointing to the generated certificate and key pair; `flask.server.{key,crt}`.
- To verify if the certificate is being served on secure port
```bash
openssl s_client -connect <VM-IP>:443 -showcerts
```

## Alternative faster way..
- `cd` into the project and run the following snippet
- *WARNING* You still need to install `git` on the VM to clone this repo on a VM and manually edit the files for routes and nginx file for server path.
```bash
chmod +x setup.sh
./setup.sh
```

## API Testing
- `GET` Request:
  - `curl 'https://<IP-ADDRESS-OR-DOMAIN-NAME>/<route>' -H 'accept: application/json'`
- `POST` Request:
  - `curl 'https://<IP-ADDRESS-OR-DOMAIN-NAME>/<route>' -H 'content-type: application/json' \
          -H 'accept: application/json, text/plain, */*'                      \
          --data-binary                                                       \
          '{ "name": "user_abc",
              "details": [{ "location" : "selection", "number" : "+12345",
                            "description" : "Creating this api" }]
            }'`
- `PUT` Request:
  - `curl 'https://<IP-ADDRESS-OR-DOMAIN-NAME>/<route>/<:id>' -X PUT          \
          -H 'content-type: application/json' -H 'accept: application/js, */*'\
          --data-binary '{ "name" : "new user name"}'`
- `DELETE` Request:
  - `curl 'https://<IP-ADDRESS-OR-DOMAIN-NAME>/<route>/<:id>' -X DELETE        \
          -H 'content-type: application/json' -H 'accept: application/json'`



## Error Handling
```bash
# For the following error, check if the correct user has the ownership of the project folder in
# /opt/api/ folder
connect() to unix:/opt/api/app.sock failed (2: No such file or directory) while connecting to upstream

# For the following error, check if the correct user has control over nginx to talk to the api
connect() to unix:/opt/api/app.sock failed (*: Permission denied) while connecting to upstream
```

## TODO
- Setup *nix based keepalivd
