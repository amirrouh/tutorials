# 1- Prerequisites 

Logging in as root
- sudo apt update && sudo apt upgrade

create a new user for django & give sudo permissions
- adduser djangouser 
- usermod -aG sudo djangouser 

Generate ssh keys on local machine 
- ssh-keygen -b 4096 
- ssh djangouser@linode_ip_address

Set the host name for the new machine 
- sudo hostnamectl set-hostname django_server 
- sudo vim /etc/hosts

add the following line:
- linode_ip django-server-name 


Make .ssh directory, add the keys, add permissions 
- mkdir -p ~/.ssh
- vim ~/.ssh/authorized_keys 

Add the public key generated on the local machine here 
- chmod -R go= ~/.ssh
- sudo chmod 700 ~/.ssh/
- sudo chmod 600 ~/.ssh/* 

Disable root login and password based login 
- sudo vim /etc/ssh/sshd_config 
- Change "PermitRootLogin no"
- Change "PasswordAuthentication no" 
- sudo systemctl restart sshd 

Firewall settings 
- sudo ufw default allow outgoing 
- sudo ufw default deny incoming 
- sudo ufw allow ssh 
- sudo ufw allow 80 
- sudo ufw enable 
- sudo ufw status 

If using pipenv instead of venv 
- vim ~/.bashrc 

add the following line:
- export PIPENV_VENV_IN_PROJECT=1 

Install required packages 
- sudo apt install pipenv python3-pip python3-dev - libpq-dev postgresql postgresql-contrib nginx curl 

Setup postgress database and user 
- sudo -u postgres psql 
- CREATE DATABASE techdanadb; 
- CREATE USER djangoadmin WITH PASSWORD '%Df5HG7^bgf4U'; 
- ALTER ROLE djangoadmin SET client_encoding TO 'utf8'; 
- ALTER ROLE djangoadmin SET default_transaction_isolation TO 'read committed'; 
- ALTER ROLE djangoadmin SET timezone TO 'UTC'; 
- GRANT ALL PRIVILEGES ON DATABASE techdanadb TO djangoadmin; 
- \q 

Setup and create django project 
- mkdir ~/myprojectdir
- cd ~/myprojectdir 
- pipenv install django gunicorn psycopg2-binary 
- pipenv shell 
- django-admin.py startproject myproject ~/myprojectdir 

Initial settings.py modifications 
- ALLOWED_HOSTS = ['your_server_domain_or_IP', 'second_domain_or_IP', . . ., 'localhost']
- DATABASES = { 'default': { 'ENGINE': 'django.db.backends.postgresql_psycopg2', 'NAME': 'myproject', 'USER': 'myprojectuser', 'PASSWORD': 'password', 'HOST': 'localhost', 'PORT': '', } } 
- STATIC_ROOT = os.path.join(BASE_DIR, 'static/') 

Complete setup by 
- python3 manage.py makemigrations 
- python3 manage.py migrate 
- python3 manage.py createsuperuser 
- python3 manage.py collectstatic 

# 2- Configure Gunicorn 
Gunicorn socket file 
- sudo vim /etc/systemd/system/gunicorn.socket 

add the followings to the file 
- [Unit]
- Description=gunicorn socket 
- [Socket]
- ListenStream=/run/gunicorn.sock 
- [Install]
- WantedBy=sockets.target 

Gunicorn create service 
- sudo vim /etc/systemd/system/gunicorn.service 

add the followings: 

- [Unit] 
- Description=gunicorn daemon 
- Requires=gunicorn.socket 
- After=network.target 
- [Service] 
- User=sammy 
- Group=www-data 
- WorkingDirectory=/home/sammy/myprojectdir 
- ExecStart=/home/sammy/myprojectdir/.venv/bin/
- gunicorn \ 
- --access-logfile - \ 
- --workers 3 \ 
- --bind unix:/run/gunicorn.sock \ 
- myproject.wsgi:application 

Gunicorn run service 
- sudo systemctl start gunicorn.socket 
- sudo systemctl enable gunicorn.socket 

Gunicorn troubleshooting tools (in case error happens) 
- sudo systemctl status gunicorn.socket /run/gunicorn.sock
- sudo tail -f /var/log/syslog 
- sudo journalctl -u gunicorn.socket 

Reload Gunicorn after fixing 
- sudo systemctl daemon-reload 
- sudo systemctl restart gunicorn 

# 3- Configure nginx 
- sudo vim /etc/nginx/sites-available/techdana 

Add the following: 

- server { 
- listen 80; 
- server_name example.com www.example.com; 
- location = /favicon.ico { access_log off;
- log_not_found off; } 
- location /static/ { 
- root /home/sammy/myprojectdir; 
} 
- location / { 
- include proxy_params; 
- proxy_pass http://unix:/run/gunicorn.sock; 
- } 
- } 

- sudo ln -s /etc/nginx/sites-available/techdana /etc/nginx/sites-enabled 
- sudo nginx -t 
- sudo systemctl restart nginx 
- sudo ufw delete allow 8000 
- sudo ufw allow 'Nginx Full' 

Enable https 
- sudo apt install certbot python3-certbot-nginx 
- sudo certbot --nginx -d example.com -d www.example.com 

# 4- Setting up Django
