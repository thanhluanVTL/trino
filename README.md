```markdown
# Trino and Superset with SSL Connection (Non-Production)
```

## Step 1: Change .env file for Init Security
1.  **Access the Superset container:**
    ```bash
    cd init-security
    ```

2.  **Access the Superset container:**
    ```bash
    nano .env
    ```
  Change STOREPASS, KEYPASS, TRINO_DOMAIN value

## Step 2: Run docker-compose.yml

  ```bash
  docker-compose up --build
  ```

## Step 3: Initialize Superset

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

## Step 4: Configure the Trino Connection in Superset

1.  **Access Superset:** Open your web browser and go to `http://localhost:8088`. Log in as an administrator.

2.  **Navigate to Databases:** Click on "Data" in the top menu, then select "Databases".

3.  **Create a New Database:** Click "+ Database" and select "SQLAlchemy URI".

4.  **Enter the SQLAlchemy Connection String:**

    ```
    trino://${username}:${password}@${trino_domain}:8443/${catalog}/${schema}
    ```

5.  **Test the Connection:** Click the "Test Connection" button.

6.  **Save the Database Connection:** Click "Save".