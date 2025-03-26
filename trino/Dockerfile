FROM trinodb/trino:472

USER trino

RUN rm -f /usr/lib/trino/bin/run-trino
COPY --chown=trino:trino entrypoint/run-trino /usr/lib/trino/bin/run-trino
RUN chmod 777 /usr/lib/trino/bin/run-trino

RUN mkdir -p /etc/trino/catalog /etc/trino/password /etc/trino/data /etc/trino/tls
RUN chmod 777 -R /etc/trino/catalog /etc/trino/password /etc/trino/data /etc/trino/tls

EXPOSE 8080