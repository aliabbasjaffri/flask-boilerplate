from multiprocessing import cpu_count

errorlog = '/var/log/gunicorn/gunicorn.log'
loglevel = 'warning'
bind = 'unix:/opt/api/app.sock'
workers = cpu_count() * 2 + 1
threads = 2
user = 'www-data'
group = 'www-data'
# Daemon turned off because of the note on the URL
# https://docs.gunicorn.org/en/latest/deploy.html#monitoring
daemon = False
