FROM apache/superset:4.1.1

USER root

COPY --chmod=777 config/superset_config.py /app/
ENV SUPERSET_CONFIG_PATH /app/superset_config.py

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

RUN rm -f /usr/local/lib/python3.10/site-packages/certifi/cacert.pem
COPY --chown=root:root cacert.pem /usr/local/lib/python3.10/site-packages/certifi/cacert.pem
RUN chmod 644 /usr/local/lib/python3.10/site-packages/certifi/cacert.pem

# WORKDIR /usr/local/share/ca-certificates

# RUN update-ca-certificates --fresh
# RUN update-ca-certificates

USER superset

WORKDIR /app

ENTRYPOINT [ "/usr/bin/run-server.sh" ]