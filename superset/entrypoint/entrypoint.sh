#!/usr/bin/env bash

# Set -e to exit immediately if a command exits with a non-zero status
set -e

echo "============================ Check Environment Variables ============================"
# Function to check if an environment variable is set and append to missing_vars if not
check_env_var() {
  local var_name="$1"
  if [[ -z "${!var_name}" ]]; then
    missing_vars+=("$var_name")  # Append the missing variable to the array
  fi
}

# Array of required environment variables
required_vars=("KEY_PROVIDER_URL")

# Array to store the names of missing environment variables
missing_vars=()

# Loop through the required variables and check if they are set
echo "Checking required environment variables ..."
for var in "${required_vars[@]}"; do
  check_env_var "$var"
done

# Check if any variables are missing
if [[ ${#missing_vars[@]} -gt 0 ]]; then
  echo "Error: The following required environment variables are not set:"
  for var in "${missing_vars[@]}"; do
    echo "  - $var"
  done
  exit 1  # Exit with a non-zero status code
fi

echo "All required environment variables are set."


echo "============================ Get Certificate File ============================"
# Function to download the file
download_file() {
  local filename="$1"
  local output_dir="$2"
  local attempt=1
  local full_path
  local http_code

  RETRIES=3
  DELAY=2
  API_URL=${KEY_PROVIDER_URL}/files

  # Check if filename is empty
  if [ -z "$filename" ]; then
    echo "Error: Filename is required as an argument to download_file."
    return 1  # Indicate failure
  fi

  # Check if output_dir is empty
  if [ -z "$output_dir" ]; then
    echo "Error: output_dir (directory) is required as an argument to download_file."
    return 1
  fi

  # Check if output_dir exists and is a directory
  if [ ! -d "$output_dir" ]; then
    echo "Error: output_dir '$output_dir' is not a directory or does not exist."
    return 1
  fi

  # API Endpoint
  url="$API_URL/$filename"

  # Construct full path
  full_path="$output_dir/$filename"

  while true; do
    echo "Attempt $attempt to download from $url to $full_path..."
    http_code=$(curl -s -o "$full_path" -w "%{http_code}" "$url")  # capture output of curl command
    local status=$?

    if [[ $status -eq 0 ]] && [[ "$http_code" -eq 200 ]]; then
      echo "Download successful (HTTP 200)!"
      return 0  # Exit the function with success

    else
      echo "Download failed (status code: $status, HTTP code: $http_code)."

      if [[ $attempt -ge $RETRIES ]]; then
        echo "Maximum retries reached. Download failed."
        return 1  # Exit the function with failure
      fi

      attempt=$((attempt + 1))
      echo "Retrying in $DELAY seconds..."
      sleep $DELAY
    fi
  done
}


OUTPUT_DIR=/app/security
FILE_NAME=trino.cert.pem

rm -f $OUTPUT_DIR/$FILE_NAME

echo -e "Download File ..."
# Call the download function and check the result
if download_file "$FILE_NAME" "$OUTPUT_DIR"; then
  echo "File saved to: $OUTPUT_DIR/$FILE_NAME"
  chmod 777 $OUTPUT_DIR/$FILE_NAME
else
  echo "File download failed after $RETRIES retries."
  exit 1
fi

BACKUP_CERTIFICATE_FILE=/usr/local/lib/python3.10/site-packages/certifi/cacert.pem.bku
MAIN_CERTIFICATE_FILE=/usr/local/lib/python3.10/site-packages/certifi/cacert.pem

echo "======================================= Copy Certificate Template ======================================="
cp -f $BACKUP_CERTIFICATE_FILE $MAIN_CERTIFICATE_FILE
chmod 777 $MAIN_CERTIFICATE_FILE

echo "======================================= Insert Certificate ======================================="
cat $OUTPUT_DIR/$FILE_NAME >> $MAIN_CERTIFICATE_FILE
echo "Appended Certificate to $MAIN_CERTIFICATE_FILE"

echo "======================================= Start Superset Service ======================================="

HYPHEN_SYMBOL='-'

gunicorn \
    --bind "${SUPERSET_BIND_ADDRESS:-0.0.0.0}:${SUPERSET_PORT:-8088}" \
    --access-logfile "${ACCESS_LOG_FILE:-$HYPHEN_SYMBOL}" \
    --error-logfile "${ERROR_LOG_FILE:-$HYPHEN_SYMBOL}" \
    --workers ${SERVER_WORKER_AMOUNT:-1} \
    --worker-class ${SERVER_WORKER_CLASS:-gthread} \
    --threads ${SERVER_THREADS_AMOUNT:-20} \
    --timeout ${GUNICORN_TIMEOUT:-60} \
    --keep-alive ${GUNICORN_KEEPALIVE:-2} \
    --max-requests ${WORKER_MAX_REQUESTS:-0} \
    --max-requests-jitter ${WORKER_MAX_REQUESTS_JITTER:-0} \
    --limit-request-line ${SERVER_LIMIT_REQUEST_LINE:-0} \
    --limit-request-field_size ${SERVER_LIMIT_REQUEST_FIELD_SIZE:-0} \
    "${FLASK_APP}"
