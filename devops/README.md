# Running with HashiCorp Vault and Docker Compose

## 1. Start Vault Server

Start Vault using the provided config file:

```bash
vault server -config=devops/vault-config.hcl
```

## 2. Initialize and Unseal Vault (first time only)

In a new terminal:

```bash
export VAULT_ADDR='http://127.0.0.1:8200'
vault operator init
vault operator unseal <unseal_key_1>
vault operator unseal <unseal_key_2>
vault operator unseal <unseal_key_3>
vault login <root_token>
```

## 3. Store Environment Variables in Vault

Add your backend environment variables:

```bash
vault kv put secret/backend \
  MONGODB_URL="mongodb://database:27017/space2study" \
  CLIENT_URL="http://YOUR_IP:3001" \
  COOKIE_DOMAIN="YOUR_IP" \
  SERVER_URL="http://YOUR_IP:3000" \
  SERVER_PORT="3000" \
  JWT_ACCESS_SECRET="generate_strong_random_secret" \
  JWT_ACCESS_EXPIRES_IN="15m" \
  JWT_REFRESH_SECRET="generate_strong_random_secret" \
  JWT_REFRESH_EXPIRES_IN="7d" \
  JWT_RESET_SECRET="generate_strong_random_secret" \
  JWT_RESET_EXPIRES_IN="7d" \
  JWT_CONFIRM_SECRET="generate_strong_random_secret" \
  JWT_CONFIRM_EXPIRES_IN="7d" \
  NODE_ENV="development"
```

Add your frontend environment variables:

```bash
vault kv put secret/frontend VITE_API_BASE_PATH="http://YOUR_IP:3000"
```

**Important Security Notes**:
- Replace `YOUR_IP` with your actual IP address (e.g., `192.168.0.108`) or use `localhost` if accessing only from the same machine
- Generate strong, unique secrets for all JWT_*_SECRET values (use tools like `openssl rand -base64 32`)
- Never commit actual secret values to version control

## 4. Run the Project

Use the provided script to fetch secrets and export environment variables:

```bash
cd devops
export VAULT_ADDR='http://127.0.0.1:8200'
source vault-env.sh
```

Then start the services with Docker Compose:

```bash
docker compose -p space2study up -d
```

The `vault-env.sh` script will:
- Fetch secrets from Vault
- Export them as environment variables in your current shell

Then you manually start the Docker Compose services with the loaded environment.

## 5. Access the Application

- **Frontend**: http://localhost:3001 or http://192.168.0.108:3001
- **Backend API**: http://localhost:3000 or http://192.168.0.108:3000
- **Database**: MongoDB running on port 27017

## 6. Stop the Services

To stop all services:

```bash
docker compose down
```
