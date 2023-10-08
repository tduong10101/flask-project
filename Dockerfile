FROM python:3.11
RUN useradd -ms /bin/bash python
USER python
WORKDIR /home/python
RUN git clone https://github.com/tduong10101/tnote.git
WORKDIR /home/python/tnote
RUN pip3 install -r requirements.txt && chmod +x tnote.sh
ENV PATH="/home/python/.local/bin:$PATH"
CMD ["bash","tnote.sh"]
