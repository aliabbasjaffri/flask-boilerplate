# Sample Flask Application Boilerplate

## Setting up Flask Application for Development Environment
- The development environment is managed by Docker and docker-compose file
- Update the variables in `docker-compose` file and run `docker-compose up`


## Setting up Flask Application for Production Environment
- Launch a VM and checkout this repository in it.
- `cd` into the project and run the following snippet
```bash
chmod +x setup.sh
./setup.sh
```
- Copy the project file to the appropriate directory
```bash
cp -R flask-boilerplate/ /opt/api
rm -rf flask-boilerplate
```
- Copy the daemon service to the `systemd` path
```bash
cp /opt/api/api.service /etc/systemd/system/
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
# To verify if the api value pasted is accurate
cat /etc/nginx/sites-available/api
# creating a link from sited available to sites enabled
ln -s /etc/nginx/sites-available/api /etc/nginx/sites-enabled
# testing the service for the updated configuration
nginx -t
systemctl restart nginx
systemctl status nginx
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

## Error Handling
```bash
# For the following error, check if the correct user has the ownership of the project folder in
# /opt/api/ folder
connect() to unix:/opt/api/app.sock failed (2: No such file or directory) while connecting to upstream

# For the following error, check if the correct user has control over nginx to talk to the api
connect() to unix:/opt/api/app.sock failed (*: Permission denied) while connecting to upstream
```