#!/bin/bash
#inputs
username="amir"
myproject="techdana"
myprojectenv="venv"

myprojectdir=$myproject

### Installing the Packages from the Ubuntu Repositories
sudo apt update
sudo apt install python3-pip python3-dev libpq-dev postgresql postgresql-contrib nginx curl -y

### Creating a Python Virtual Environment for your Project
sudo -H pip3 install --upgrade pip
sudo -H pip3 install virtualenv
mkdir ~/$myprojectdir
cd ~/$myprojectdir
virtualenv $myprojectenv
. ~/$myprojectdir/$myprojectenv/bin/activate
python -m pip install --upgrade pip
pip install django gunicorn psycopg2-binary
deactivate

### Creating and Configuring a New Django Project
. ~/$myprojectdir/$myprojectenv/bin/activate
cd ~/$myprojectdir
django-admin startproject $myproject ~/$myprojectdir
python3 manage.py makemigrations
python3 manage.py migrate

# Editing settings.py file in terminal
python3 /home/$username/django/modify_settings.py
python3 manage.py collectstatic

### Testing Gunicorn’s Ability to Serve the Project
sudo ufw allow 8000
# cd ~/$myprojectdir
# gunicorn --bind 0.0.0.0:8000 $myproject.wsgi
deactivate

### Creating systemd Socket and Service Files for Gunicorn
sudo sh /home/$username/django/create_services.sh $username $myproject $myprojectdir


sudo systemctl start gunicorn.socket
sudo systemctl enable gunicorn.socket
