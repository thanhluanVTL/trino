# key-provider for localhost
cd security/
keytool -genkey -alias trino1 -keyalg RSA -keystore keystore-localhost.jks -storepass qazwsx -keypass qazwsx -validity 3650 -keysize 2048 -dname "CN=localhost, OU=Example, O=Example, L=Example, S=Example, C=US"
keytool -exportcert -alias trino1 -keystore keystore-localhost.jks -file trino-localhost.cert.der -storepass qazwsx
openssl x509 -inform der -in trino-localhost.cert.der -out trino.cert-localhost.pem

# Trino-coordinator
cd /etc/trino/tls
curl -o trino.cert-localhost.pem  http://key-provider:8000/files/trino.cert-localhost.pem
keytool -import -trustcacerts -alias trino1 -file /etc/trino/tls/trino.cert-localhost.pem -keystore $JAVA_HOME/lib/security/cacerts -storepass qazwsx
$JAVA_HOME/lib/security/cacerts




# Connect to Trino using CLI
trino --server https://localhost:8443 --keystore-path /etc/trino/tls/keystore.jks --keystore-password changeit --user luanvt --password
trino --server https://localhost:8443 --keystore-path /etc/trino/tls/keystore.jks --keystore-password changeit --catalog system --user luanvt --password
trino --server https://192.168.44.179:8443 --keystore-path /etc/trino/tls/keystore.jks --keystore-password qazwsx --catalog system --user luanvt --password


trino --server https://localhost:8443 --keystore-path /etc/trino/tls/keystore-localhost.jks --keystore-password qazwsx --catalog system --user luanvt --password

trino --server https://localhost:8443 --insecure --catalog system --user luanvt --password

# Use
use ${catalog}
use ${catalog}.${schema}

# Create table
CREATE TABLE postgres.public.customers (
    customer_id INTEGER,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email VARCHAR(255),
    registration_date DATE
);

# Insert
INSERT INTO customers (customer_id, first_name, last_name, email, registration_date)
VALUES
    (1, 'John', 'Doe', 'john.doe@example.com', DATE '2023-11-01'),
    (2, 'Jane', 'Smith', 'jane.smith@example.com', DATE '2023-11-05');


