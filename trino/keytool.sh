# Generate TLS Keystore

keytool -genkey -alias trino -keyalg RSA -keystore config/coordinator/keystore.jks -storepass changeit -keypass changeit -validity 3650 -keysize 2048 -dname "CN=localhost, OU=Example, O=Example, L=Example, S=Example, C=US"

keytool -list -v -keystore config/coordinator/keystore.jks -storepass changeit


keytool -genkey -alias trino -keyalg RSA -keystore keystore.jks -storepass qazwsx -keypass qazwsx -validity 3650 -keysize 2048 -dname "CN=trino-cluster.luanvt.com, OU=Example, O=Example, L=Example, S=Example, C=US"
keytool -list -v -keystore keystore.jks -storepass qazwsx

keytool -genkey -alias trino -keyalg RSA -keystore keystore.jks -storepass qazwsx -keypass qazwsx -validity 3650 -keysize 2048 -dname "CN=192.168.44.50, OU=Example, O=Example, L=Example, S=Example, C=US"