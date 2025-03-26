```markdown
## Trino and Superset with SSL Connection
```

## Step 1: Create addtional mount data folders
    ```bash
    mkdir -p data/pgadmin data/postgres data/superset
    chmod 777 -R data/pgadmin data/postgres data/superset
    ```

## Step 2: Change .env files
1.  **Go to key-provider folder and edit .env file:**
    ```bash
    cd key-provider
    nano .env
    # Then change STOREPASS, KEYPASS, TRINO_DOMAIN value
    ```

2.  **Go to trino folder and edit .env file:**
    ```bash
    cd trino
    nano .env
    # Then change KEY_PROVIDER_URL value
    ```

3.  **Go to superset folder and edit .env file:**
    ```bash
    cd superset
    nano .env
    # Then change SUPERSET_PORT and KEY_PROVIDER_URL value
    ```

## Step 3: Run docker-compose.yml

  ```bash
  # Run with existing images on Docker Hub
  docker-compose -f docker-compose-deploy.yml up -d

  # Build images to run
  docker-compose -f docker-compose-local.yml up -d --build
  ```

## Step 4: Initialize Superset

1.  **Access the Superset container:**

    ```bash
    docker exec -it superset bash
    ```

2.  **Run the initialization commands:**

    ```bash
    superset db upgrade
    superset fab create-admin --username admin --password admin --firstname Superset --lastname Admin --email admin@example.com
    superset init
    ```

## Step 5: Configure the Trino Connection in Superset

1.  **Access Superset:** Open your web browser and go to `http://localhost:8088`. Log in as an administrator.

2.  **Navigate to Databases:** Click on "Data" in the top menu, then select "Databases".

3.  **Create a New Database:** Click "+ Database" and select "SQLAlchemy URI".

4.  **Enter the SQLAlchemy Connection String:**

    ```
    trino://${username}:${password}@${trino_domain}:8443/${catalog}/${schema}
    ```

5.  **Test the Connection:** Click the "Test Connection" button.

6.  **Save the Database Connection:** Click "Save".