# Extract the Certificate and Key (PEM format)

# qazwsx
keytool -importkeystore -srckeystore config/coordinator/keystore.jks -destkeystore temp.p12 -deststoretype PKCS12
keytool -importkeystore -srckeystore keystore.jks -destkeystore temp.p12 -deststoretype PKCS12 -srcstorepass changeit -deststorepass qazwsx
keytool -importkeystore -srckeystore keystore.jks -destkeystore temp.p12 -deststoretype PKCS12 -srcstorepass qazwsx -deststorepass qazwsx



openssl pkcs12 -in temp.p12 -cacerts -nokeys -out trino.cert.pem
openssl pkcs12 -in temp.p12 -nocerts -nodes -out trino.key.pem

openssl pkcs12 -in temp.p12 -cacerts -nokeys -out trino.cert.pem -passin pass:qazwsx
openssl pkcs12 -in temp.p12 -nocerts -nodes -out trino.key.pem -passin pass:qazwsx



keytool -exportcert -alias trino -keystore keystore.jks -file trino.cert.der -storepass qazwsx
openssl x509 -inform der -in trino.cert.der -out trino.cert.pem