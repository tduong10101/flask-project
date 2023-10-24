cd /home/python/tnote
/home/python/.local/bin/gunicorn -D -w 4 -b 0.0.0.0:8000 "website:create_app()"
