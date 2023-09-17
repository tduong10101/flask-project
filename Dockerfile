FROM python:latest
RUN useradd -ms /bin/bash python
USER python
WORKDIR /home/python
RUN git clone https://github.com/tduong10101/tnote.git
WORKDIR /home/python/flask-project
RUN pip3 install -r requirements.txt && chmod +x tnote.sh
CMD ["bash","tnote.sh"]
