FROM python:latest
RUN useradd -ms /bin/bash python
USER python
WORKDIR /home/python
RUN git clone https://github.com/tduong10101/flask-project.git
WORKDIR /home/python/flask-project
RUN pip3 install -r requirements.txt
