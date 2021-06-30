username=$1
myproject=$2
myprojectdir=$3
myprojectenv="venv"


cat >/etc/systemd/system/gunicorn.socket <<EOL
[Unit]
Description=gunicorn socket

[Socket]
ListenStream=/run/gunicorn.sock

[Install]
WantedBy=sockets.target
EOL

cat >/etc/systemd/system/gunicorn.service <<EOL
[Unit]
Description=gunicorn daemon
Requires=gunicorn.socket
After=network.target

[Service]
User=$username
Group=www-data
WorkingDirectory=/home/$username/$myprojectdir
ExecStart=/home/$username/$myprojectdir/$myprojectenv/bin/gunicorn \
          --access-logfile - \
          --workers 3 \
          --bind unix:/run/gunicorn.sock \
          $myproject.wsgi:application

[Install]
WantedBy=multi-user.target
EOL
