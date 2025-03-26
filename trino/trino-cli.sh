trino --server https://localhost:8443 --keystore-path /etc/trino/tls/keystore.jks --keystore-password changeit --user luanvt --password
trino --server https://localhost:8443 --keystore-path /etc/trino/tls/keystore.jks --keystore-password changeit --catalog system --user luanvt --password


# 1
use ${catalog}
use ${catalog}.${schema}
