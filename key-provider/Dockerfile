FROM openjdk:25-slim-bullseye

USER root

# Install Tools
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

# Create working folders
RUN mkdir -p /apps/security && chmod 777 -R /apps/security

# Working folder
WORKDIR /apps

# Install python packages
COPY requirements.txt /apps/requirements.txt
RUN pip install -r /apps/requirements.txt

# API source
COPY apps/main.py /apps/main.py

# Entrypoint
COPY --chown=root:root entrypoint/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

# Expose service port
EXPOSE 8000