FROM apache/superset:4.1.1

USER root

COPY --chmod=777 config/superset_config.py /app/
ENV SUPERSET_CONFIG_PATH /app/superset_config.py

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

# RUN rm -f /usr/local/lib/python3.10/site-packages/certifi/cacert.pem
# COPY --chown=root:root security/cacert.pem /usr/local/lib/python3.10/site-packages/certifi/cacert.pem
RUN chmod 777 /usr/local/lib/python3.10/site-packages/certifi/cacert.pem

RUN rm -f /usr/bin/run-server.sh
COPY entrypoint/run-server.sh /usr/bin/run-server.sh
RUN chmod 777 /usr/bin/run-server.sh

USER superset

WORKDIR /app

ENTRYPOINT [ "/usr/bin/run-server.sh" ]