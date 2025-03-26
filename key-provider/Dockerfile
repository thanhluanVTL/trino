FROM openjdk:25-slim-bullseye

USER root

RUN apt-get update && apt-get -y dist-upgrade \
&& apt-get install -y --no-install-recommends \
apache2-utils \
build-essential \
curl \
nano \
openssl \
python3.9 \
python3.9-dev \
python3-pip \
wget \
&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /apps/security && chmod 777 -R /apps/security
COPY requirements.txt /apps/requirements.txt
RUN pip install -r /apps/requirements.txt
COPY apps/main.py /apps/main.py

COPY --chown=root:root entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /apps

ENTRYPOINT [ "/entrypoint.sh" ]

EXPOSE 8000