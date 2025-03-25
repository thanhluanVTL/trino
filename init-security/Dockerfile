FROM openjdk:25-slim-bullseye

USER root

RUN apt-get update && apt-get -y dist-upgrade \
&& apt-get install -y apache2-utils nano openssl \
&& rm -rf /var/lib/apt/lists/*

COPY --chown=root:root entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN mkdir /security && chmod 777 -R /security

WORKDIR /security

ENTRYPOINT [ "/entrypoint.sh" ]