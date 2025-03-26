# FROM apache/superset:4.1.1

# USER root

# # Install Tools
# RUN apt-get update && apt-get -y dist-upgrade \
# && apt-get install -y --no-install-recommends \
# curl \
# nano \
# wget \
# && rm -rf /var/lib/apt/lists/*

# COPY --chmod=777 config/superset_config.py /app/
# ENV SUPERSET_CONFIG_PATH /app/superset_config.py

# COPY requirements.txt requirements.txt
# RUN pip install -r requirements.txt

# RUN chmod 777 /usr/local/lib/python3.10/site-packages/certifi/cacert.pem

# RUN rm -f /usr/bin/run-server.sh
# COPY entrypoint/run-server.sh /usr/bin/run-server.sh
# RUN chmod 777 /usr/bin/run-server.sh

# RUN mkdir -p /app/security && chown superset:superset /app/security

# USER superset

# WORKDIR /app

# # Entrypoint
# # ENTRYPOINT [ "/usr/bin/run-server.sh" ]




FROM apache/superset:4.1.1

USER root

# Install Tools
RUN apt-get update && apt-get -y dist-upgrade \
&& apt-get install -y --no-install-recommends \
curl \
nano \
wget \
&& rm -rf /var/lib/apt/lists/*

# Install python packages
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

# Certificate
RUN cp /usr/local/lib/python3.10/site-packages/certifi/cacert.pem /usr/local/lib/python3.10/site-packages/certifi/cacert.pem.bku \
&& chown superset:superset /usr/local/lib/python3.10/site-packages/certifi/cacert.pem /usr/local/lib/python3.10/site-packages/certifi/cacert.pem.bku \
&& chmod 777 /usr/local/lib/python3.10/site-packages/certifi/cacert.pem /usr/local/lib/python3.10/site-packages/certifi/cacert.pem.bku

# Create folder to save certificate file
RUN mkdir -p /app/security && chown superset:superset /app/security

# Superset config file
COPY --chmod=777 config/superset_config.py /app/
ENV SUPERSET_CONFIG_PATH /app/superset_config.py

# Entrypoint
RUN rm -f /usr/bin/run-server.sh
COPY entrypoint/entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod 777 /usr/bin/entrypoint.sh
ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]

# Using superset user
USER superset

# Working folder
WORKDIR /app

# Expose service port
EXPOSE 8088