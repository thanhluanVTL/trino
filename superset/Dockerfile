FROM apache/superset:4.1.1

USER root

RUN apt-get update && apt-get -y dist-upgrade \
&& apt-get install -y --no-install-recommends \
curl \
nano \
wget \
&& rm -rf /var/lib/apt/lists/*

COPY --chmod=777 config/superset_config.py /app/
ENV SUPERSET_CONFIG_PATH /app/superset_config.py

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

RUN chmod 777 /usr/local/lib/python3.10/site-packages/certifi/cacert.pem

RUN rm -f /usr/bin/run-server.sh
COPY entrypoint/run-server.sh /usr/bin/run-server.sh
RUN chmod 777 /usr/bin/run-server.sh

RUN mkdir -p /app/security && chown superset:superset /app/security

USER superset

WORKDIR /app

ENTRYPOINT [ "/usr/bin/run-server.sh" ]