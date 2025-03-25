```markdown
# Trino and Superset with SSL Connection (Non-Production)

This README provides step-by-step instructions to set up Trino and Superset in Docker Compose, configured for a secure SSL connection from Superset to Trino, **for NON-PRODUCTION use only.**

**WARNING:** This setup uses self-signed certificates and is **not suitable for production environments.** Use certificates from a trusted Certificate Authority (CA) in production.

## Prerequisites

*   Docker
*   Docker Compose
*   Basic understanding of Trino and Superset

## Directory Structure

Create the following directory structure:

```
trino-superset-ssl/
├── config/
│   ├── coordinator/
│   │   ├── config.properties
│   │   ├── jvm.config
│   │   └── node.properties
│   ├── password/
│   │   └── password.db
│   ├── access-control/
│   │   └── access-control.json
│   └── worker/
│       ├── config.properties
│       ├── jvm.config
│       └── node.properties
├── superset_certs/
├── docker-compose.yml
└── Dockerfile.trino
```

## Step 1: Create the Trino Dockerfile (Dockerfile.trino)

```dockerfile
# Use the official Trino image as the base
FROM trinodb/trino:latest

# Install any extra dependencies if needed.  For example, if you want to use a specific connector
# RUN apt-get update && apt-get install -y some-package

# Create necessary directories for configurations (if needed)
RUN mkdir -p /etc/trino/catalog
RUN mkdir -p /etc/trino/password

# Expose Trino's standard port (8080)
EXPOSE 8080

# Define the user to run Trino as.  This is important for permissions.  The default is 'trino'.
USER trino
```

## Step 2: Coordinator Configuration Files (`config/coordinator`)

*   **`config/coordinator/node.properties`**

    ```properties
    node.environment=trino
    node.id=coordinator
    node.data-dir=/var/trino/data
    plugin.dir=/usr/lib/trino/plugin
    discovery.uri=http://coordinator:8080
    ```

*   **`config/coordinator/jvm.config`**

    ```
    -server
    -Xmx16G
    -XX:+UseG1GC
    -XX:G1HeapRegionSize=32M
    -XX:+UseGCOverheadLimit
    -XX:ReservedCodeCacheSize=512M
    -XX:NonHeapSize=256M
    -Djdk.tls.ephemeralDHKeySize=2048
    -Djdk.tls.rejectClientInitiatedRenegotiation=true
    -Djava.net.preferIPv4Stack=true
    -XX:+HeapDumpOnOutOfMemoryError
    -XX:HeapDumpPath=/var/trino/data/heapdump.hprof
    ```

*   **`config/coordinator/config.properties`**

    ```properties
    coordinator=true
    node-scheduler.include-coordinator=true
    http-server.http.port=8080
    http-server.https.enabled=true
    http-server.https.port=8443
    http-server.https.keystore.path=/etc/trino/tls/keystore.jks
    http-server.https.keystore.key=changeit
    discovery-server.enabled=true
    discovery.uri=http://coordinator:8080
    query.max-memory=5GB
    query.max-memory-per-node=1GB
    task.concurrency=16
    access-control.name=file
    access-control.config-file=/etc/trino/access-control/access-control.json
    authentication.type=password
    password-authenticator.type=file
    password-authenticator.password-file=/etc/trino/password/password.db
    ```

## Step 3: Worker Configuration Files (`config/worker`)

*   **`config/worker/node.properties`**

    ```properties
    node.environment=trino
    node.id=worker1
    node.data-dir=/var/trino/data
    plugin.dir=/usr/lib/trino/plugin
    discovery.uri=http://coordinator:8080
    ```

*   **`config/worker/jvm.config`**

    ```
    -server
    -Xmx16G
    -XX:+UseG1GC
    -XX:G1HeapRegionSize=32M
    -XX:+UseGCOverheadLimit
    -XX:ReservedCodeCacheSize=512M
    -XX:NonHeapSize=256M
    -Djdk.tls.ephemeralDHKeySize=2048
    -Djdk.tls.rejectClientInitiatedRenegotiation=true
    -Djava.net.preferIPv4Stack=true
    -XX:+HeapDumpOnOutOfMemoryError
    -XX:HeapDumpPath=/var/trino/data/heapdump.hprof
    ```

*   **`config/worker/config.properties`**

    ```properties
    coordinator=false
    http-server.http.port=8080
    http-server.https.enabled=true
    http-server.https.port=8443
    http-server.https.keystore.path=/etc/trino/tls/keystore.jks
    http-server.https.keystore.key=changeit
    discovery.uri=http://coordinator:8080
    query.max-memory=5GB
    query.max-memory-per-node=1GB
    task.concurrency=16
    ```

## Step 4: Password File (`config/password/password.db`)

Create a file with usernames and bcrypt hashed passwords:

```
user1:bcrypt$2a$10$e9B28XgLqj04gE4u.g3P6u/fF.T6L7lY.kXjH8.G0QWw.7R.Xy8G
```

*   Replace `user1` with the desired username.
*   Replace the bcrypt string with a correctly hashed password.
*   Set file permissions: `chmod 600 config/password/password.db`

## Step 5: Access Control File (`config/access-control/access-control.json`)

```json
{
  "catalogs": [
    {
      "user": "user1",
      "catalog": "system",
      "allow": "all"
    },
    {
      "user": "user1",
      "catalog": "tpch",
      "allow": "all"
    }
  ],
  "principals": [
    {
      "user": "user1",
      "allow": "all"
    }
  ],
  "roles": [
    {
      "role": "admin",
      "allow": "all"
    }
  ],
  "global": [
    {
      "user": "user1",
      "allow": "all"
    }
  ]
}
```

## Step 6: Generate TLS Keystore (keystore.jks)

```bash
keytool -genkey -alias trino -keyalg RSA -keystore config/coordinator/keystore.jks -storepass changeit -keypass changeit -validity 3650 -keysize 2048 -dname "CN=localhost, OU=Example, O=Example, L=Example, S=Example, C=US"
```

## Step 7: Extract the Certificate and Key (PEM format)

1.  **Export from JKS to PKCS12:**

    ```bash
    keytool -importkeystore -srckeystore config/coordinator/keystore.jks -destkeystore temp.p12 -deststoretype PKCS12 -srcstorepass changeit -deststorepass changeit
    ```

2.  **Extract the Certificate (trino.cert.pem):**

    ```bash
    openssl pkcs12 -in temp.p12 -cacerts -nokeys -out superset_certs/trino.cert.pem -passin pass:changeit
    ```

3.  **Extract the Private Key (trino.key.pem):**

    ```bash
    openssl pkcs12 -in temp.p12 -nocerts -nodes -out superset_certs/trino.key.pem -passin pass:changeit
    ```

    **Verify the File:** Use `ls -l superset_certs/trino.cert.pem` to ensure there's data within it.

## Step 8: Docker Compose File (`docker-compose.yml`)

```yaml
version: "3.8"

services:
  trino-coordinator:
    image: trino:latest
    build:
      context: .
      dockerfile: Dockerfile.trino
    container_name: trino-coordinator
    ports:
      - "8080:8080"
      - "8443:8443"
    volumes:
      - ./config/coordinator/config.properties:/etc/trino/config.properties
      - ./config/coordinator/jvm.config:/etc/trino/jvm.config
      - ./config/coordinator/node.properties:/etc/trino/node.properties
      - ./config/coordinator/keystore.jks:/etc/trino/tls/keystore.jks
      - ./config/access-control/access-control.json:/etc/trino/access-control/access-control.json
      - ./config/password/password.db:/etc/trino/password/password.db
    networks:
      - trino-net
    depends_on:
      - trino-worker1

  trino-worker1:
    image: trino:latest
    build:
      context: .
      dockerfile: Dockerfile.trino
    container_name: trino-worker1
    volumes:
      - ./config/worker/config.properties:/etc/trino/config.properties
      - ./config/worker/jvm.config:/etc/trino/jvm.config
      - ./config/worker/node.properties:/etc/trino/node.properties
      - ./config/coordinator/keystore.jks:/etc/trino/tls/keystore.jks # Share the keystore
    networks:
      - trino-net
    depends_on:
      - trino-coordinator

  superset:
    image: apache/superset:latest
    container_name: superset
    ports:
      - "8088:8088"
    environment:
      SUPERSET_USERNAME: admin
      SUPERSET_PASSWORD: admin
      SUPERSET_EMAIL: admin@example.com
    volumes:
      - superset_data:/app/superset_home
      - ./superset_certs:/etc/superset_certs
    depends_on:
      - postgres
      - trino-coordinator
    restart: unless-stopped
    networks:
      - trino-net

  postgres:
    image: postgres:15.1
    container_name: superset_db
    environment:
      POSTGRES_USER: superset
      POSTGRES_PASSWORD: superset
      POSTGRES_DB: superset
    volumes:
      - superset_db_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: unless-stopped
    networks:
      - trino-net

volumes:
  superset_data:
  superset_db_data:

networks:
  trino-net:
    driver: bridge
```

## Step 9: Run Docker Compose

1.  **Navigate to the `trino-superset-ssl` directory** in your terminal.
2.  **Run `docker-compose up -d`** This will build the Trino image, create the containers, and start them in detached mode.

## Step 10: Initialize Superset

1.  **Access the Superset container:**

    ```bash
    docker exec -it superset bash
    ```

2.  **Run the initialization commands:**

    ```bash
    superset db upgrade
    superset fab create-admin --username admin --password admin --firstname Superset --lastname Admin --email admin@example.com
    superset load_examples
    superset init
    ```

## Step 11: Configure the Trino Connection in Superset

1.  **Access Superset:** Open your web browser and go to `http://localhost:8088`. Log in as an administrator.

2.  **Navigate to Databases:** Click on "Data" in the top menu, then select "Databases".

3.  **Create a New Database:** Click "+ Database" and select "SQLAlchemy URI".

4.  **Enter the SQLAlchemy Connection String:**

    ```
    trino://user1:bcrypt$2a$10$e9B28XgLqj04gE4u.g3P6u/fF.T6L7lY.kXjH8.G0QWw.7R.Xy8G@trino-coordinator:8443/system/runtime?ssl=true&ssl_cert_file=/etc/superset_certs/trino.cert.pem&ssl_key_file=/etc/superset_certs/trino.key.pem
    ```

    *Replace placeholder with your credentials*

5.  **Test the Connection:** Click the "Test Connection" button.

6.  **Save the Database Connection:** Click "Save".

## Step 12: Create Datasets and Explore Data

You should now be able to create datasets from your Trino tables and explore the data using Superset.

## Troubleshooting

*   **Superset Logs:** Check the Superset logs (`docker logs superset`) for any errors.
*   **`curl` Test:** Inside the Superset container, use `curl` to test the connection to the Trino endpoint: `curl -v --cert /etc/superset_certs/trino.cert.pem --key /etc/superset_certs/trino.key.pem  https://trino-coordinator:8443/v1/statement`
*   **OpenSSL Connection Test:** Inside the Superset container test connectivity using `openssl s_client -connect trino-coordinator:8443  -cert /etc/superset_certs/trino.cert.pem -key /etc/superset_certs/trino.key.pem`

## Important Reminders

*   **Non-Production Only:** This approach is only suitable for testing and development environments where security is not a primary concern.
*   **Security Risk:** Disabling SSL verification makes your connection vulnerable to man-in-the-middle attacks. Even though that should be disabled, it's important to test.
*   **Alternative (Preferred):** If you need a secure connection in a real environment, obtain a certificate from a trusted Certificate Authority (CA).
*   **Ensure your KeyStore passwords and Trino credentials are valid, up-to-date, and properly referenced.** This is the most likely cause.

```
```

This README provides a comprehensive guide to setting up Trino and Superset with SSL in a Docker Compose environment. Remember to adapt it to your specific needs and prioritize security in a production environment by using real certificates.