cd /home/python/tnote
nohup /home/python/.local/bin/gunicorn -w 4 -b 0.0.0.0:8000 "website:create_app()" &
