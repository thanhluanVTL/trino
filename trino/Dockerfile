FROM trinodb/trino:472

# USER root
# RUN chmod 777 /usr/lib/jvm/temurin/jdk-23.0.2+7/lib/security/cacerts

# USER trino

# Create Trino config folders
RUN mkdir -p /etc/trino/catalog /etc/trino/password /etc/trino/data /etc/trino/tls
RUN chmod 777 -R /etc/trino/catalog /etc/trino/password /etc/trino/data /etc/trino/tls

# Entrypoint
# RUN rm -f /usr/lib/trino/bin/run-trino
# COPY --chown=trino:trino entrypoint/run-trino /usr/lib/trino/bin/run-trino
# RUN chmod 777 /usr/lib/trino/bin/run-trino

RUN rm -f /usr/lib/trino/bin/run-trino
COPY --chown=trino:trino entrypoint/entrypoint.sh /usr/lib/trino/bin/entrypoint.sh
RUN chmod 777 /usr/lib/trino/bin/entrypoint.sh
ENTRYPOINT [ "/usr/lib/trino/bin/entrypoint.sh" ]

EXPOSE 8080