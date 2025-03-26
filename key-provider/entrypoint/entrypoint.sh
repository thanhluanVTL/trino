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
required_vars=(
  "STOREPASS"
  "KEYPASS"
  "TRINO_DOMAIN"
)

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


MAIN_DIR=/apps/security

echo "============================ Remove All Existing Files ============================"
rm -rf ${MAIN_DIR}/*
echo "[X] Removed all old files"

# Generate TLS Keystore
STOREPASS=${STOREPASS}
KEYPASS=${KEYPASS}
TRINO_DOMAIN=${TRINO_DOMAIN}

# STOREPASS=qazwsx
# KEYPASS=qazwsx
# TRINO_DOMAIN=192.168.44.50
KEYSTORE_FILE_PATH=${MAIN_DIR}/keystore.jks

echo -e "\n============================ Generate TLS Keystore ============================"
echo "[1] Generate new TLS keystore ..."
keytool -genkey -alias trino -keyalg RSA -keystore ${KEYSTORE_FILE_PATH} -storepass ${STOREPASS} -keypass ${KEYPASS} -validity 3650 -keysize 2048 -dname "CN=${TRINO_DOMAIN}, OU=Example, O=Example, L=Example, S=Example, C=US"
ls -l ${KEYSTORE_FILE_PATH}

echo -e "\n[2] Check TLS keystore ..."
keytool -list -v -keystore ${KEYSTORE_FILE_PATH} -storepass ${STOREPASS}


# Generate Cert
PKCS12_FILE_PATH=${MAIN_DIR}/temp.p12
CERTIFICATE_FILE_PATH=${MAIN_DIR}/trino.cert.pem
PRIVATE_KEY_FILE_PATH=${MAIN_DIR}/trino.key.pem

echo -e "\n============================ Extract the Certificate and Key (PEM format) ============================"
echo "[1] Export from JKS to PKCS12"
keytool -importkeystore -srckeystore ${KEYSTORE_FILE_PATH} -destkeystore ${PKCS12_FILE_PATH} -deststoretype PKCS12 -srcstorepass ${STOREPASS} -deststorepass ${STOREPASS}
ls -l ${PKCS12_FILE_PATH}

echo -e "\n[2] Extract the Certificate (trino.cert.pem)"
# Method 1
# openssl pkcs12 -in ${PKCS12_FILE_PATH} -cacerts -nokeys -out ${CERTIFICATE_FILE_PATH} -passin pass:${STOREPASS}

# Method 2
# Extract Certificate to a Temporary File (binary)
echo "[2.1] Extract Certificate to a Temporary File (binary) (trino.cert.der)"
keytool -exportcert -alias trino -keystore ${KEYSTORE_FILE_PATH} -file ${MAIN_DIR}/trino.cert.der -storepass ${STOREPASS}
# Convert DER to PEM
echo -e "\n[2.2] Convert DER to PEM"
openssl x509 -inform der -in ${MAIN_DIR}/trino.cert.der -out ${CERTIFICATE_FILE_PATH}
ls -l ${CERTIFICATE_FILE_PATH}

echo -e "\n[3] Extract the Private Key (trino.key.pem)"
openssl pkcs12 -in ${PKCS12_FILE_PATH} -nocerts -nodes -out ${PRIVATE_KEY_FILE_PATH} -passin pass:${STOREPASS}
ls -l ${PRIVATE_KEY_FILE_PATH}

chmod 777 -R ${MAIN_DIR}/
ls -l ${MAIN_DIR}/


echo "============================ Start API Service ============================"
exec python3 main.py