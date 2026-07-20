# Terraform - Day 7 Notes

# Securing Terraform

## Why Security Matters?

Terraform often works with sensitive infrastructure data such as:

* AWS Access Keys
* Secret Keys
* Database Passwords
* SSH Keys
* API Tokens
* Cloud Credentials

Hardcoding these values inside Terraform files is a security risk.

Instead, Terraform provides several ways to manage sensitive information securely.

---

# Ways to Secure Terraform

There are four common approaches:

1. Sensitive Variables
2. Secret Management Systems
3. Remote Backend Encryption
4. Environment Variables

---

# 1. Sensitive Variables

Terraform allows variables and outputs to be marked as **sensitive**.

When marked as sensitive:

* Value is hidden from console output.
* Value is hidden in Terraform output.
* Reduces accidental exposure.

Example:

```hcl id="h1o3qe"
variable "aws_access_key_id" {
  sensitive = true
}
```

### When to Use

* Passwords
* API Keys
* Access Keys
* Tokens

> **Note:** Marking a variable as `sensitive` only hides it from output. It may still exist in the state file, so additional protection is required.

---

# 2. Secret Management Systems

Instead of storing secrets inside Terraform files, keep them in a dedicated secret management service.

Popular options:

* HashiCorp Vault
* AWS Secrets Manager
* Azure Key Vault
* Google Secret Manager

Terraform reads secrets dynamically whenever required.

Example using Vault:

```hcl id="3rm7xm"
data "vault_generic_secret" "aws_access_key_id" {
  path = "secret/aws/access_key_id"
}

variable "aws_access_key_id" {
  value = data.vault_generic_secret.aws_access_key_id.value
}
```

### Benefits

* Secrets are never hardcoded.
* Centralized secret management.
* Better security.
* Easy secret rotation.

---

# 3. Remote Backend

The Terraform state file can contain sensitive information.

Instead of storing it locally, use a secure remote backend.

Common choices:

* Amazon S3
* Terraform Cloud

Example:

```text id="j5u3li"
S3 Bucket
      │
Encrypted State File
```

Benefits:

* Encryption
* Centralized storage
* Team collaboration
* Backup
* Better security

---

# 4. Environment Variables

Sensitive values can also be supplied through environment variables.

Example:

```bash id="f7bx9m"
export AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY_ID
```

Terraform reads the environment variable instead of storing the value inside the code.

Example:

```hcl id="sujlq4"
variable "aws_access_key_id" {
  source = "env://AWS_ACCESS_KEY_ID"
}
```

### Benefits

* Keeps credentials outside Terraform files.
* Useful for CI/CD pipelines.
* Avoids committing secrets to Git.

---

# Security Comparison

| Method                | Best For              |
| --------------------- | --------------------- |
| Sensitive Variables   | Hide output values    |
| Environment Variables | Temporary credentials |
| Secret Managers       | Production secrets    |
| Remote Backend        | Secure state storage  |

---

# HashiCorp Vault

## What is Vault?

HashiCorp Vault is a secret management system used to securely store and control access to sensitive information.

Vault can manage:

* Passwords
* Tokens
* API Keys
* Certificates
* Database Credentials
* Cloud Credentials

Terraform can retrieve secrets directly from Vault whenever needed.

---

# Vault Integration Workflow

```text id="2m2zun"
Terraform
      │
      ▼
HashiCorp Vault
      │
      ▼
Secrets
      │
      ▼
AWS Resources
```

Terraform never needs hardcoded credentials.

---

# Installing Vault

## Step 1 - Update Packages

```bash id="0lq0gs"
sudo apt update && sudo apt install gpg
```

---

## Step 2 - Download HashiCorp Signing Key

```bash id="wtm12b"
wget -O- https://apt.releases.hashicorp.com/gpg | \
sudo gpg --dearmor \
-o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

---

## Step 3 - Verify the Key

```bash id="llv5mt"
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
```

---

## Step 4 - Add HashiCorp Repository

```bash id="ks2ruv"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```

Update package information:

```bash id="mf3sdd"
sudo apt update
```

---

## Step 5 - Install Vault

```bash id="o1evvv"
sudo apt install vault
```

---

# Start Vault

Run Vault in development mode:

```bash id="4cwyph"
vault server -dev -dev-listen-address="0.0.0.0:8200"
```

Development mode is useful for learning and testing only.

---

# AppRole Authentication

Terraform commonly authenticates with Vault using **AppRole Authentication**.

AppRole is designed for applications and automation tools instead of human users.

---

## Step 1 - Enable AppRole

```bash id="1j7gz8"
vault auth enable approle
```

---

## Step 2 - Create a Policy

Example policy:

```bash id="xjlwmj"
vault policy write terraform - <<EOF
path "*" {
  capabilities = ["list", "read"]
}

path "secrets/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "kv/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "auth/token/create" {
  capabilities = ["create", "read", "update", "list"]
}
EOF
```

The policy defines what Terraform is allowed to access inside Vault.

---

## Step 3 - Create an AppRole

```bash id="6n1jow"
vault write auth/approle/role/terraform \
    secret_id_ttl=10m \
    token_num_uses=10 \
    token_ttl=20m \
    token_max_ttl=30m \
    secret_id_num_uses=40 \
    token_policies=terraform
```

This creates an AppRole named **terraform** with controlled access and token limits.

---

## Step 4 - Get the Role ID

```bash id="g0ecf7"
vault read auth/approle/role/terraform/role-id
```

The **Role ID** acts as the application's identity.

Store it securely.

---

## Step 5 - Generate a Secret ID

```bash id="bgqxiu"
vault write -f auth/approle/role/terraform/secret-id
```

The **Secret ID** acts like a password for the AppRole.

It should also be stored securely.

---

# Authentication Flow

```text id="65zw5w"
Terraform
      │
Role ID
      │
Secret ID
      ▼
HashiCorp Vault
      │
      ▼
Authentication Successful
      │
      ▼
Retrieve Secrets
      │
      ▼
Deploy Infrastructure
```

---

# Best Practices

* Never hardcode credentials in Terraform files.
* Never commit secrets to Git.
* Use `sensitive = true` for sensitive variables.
* Prefer a secret management system (Vault or AWS Secrets Manager) for production.
* Store Terraform state in an encrypted remote backend.
* Rotate credentials regularly.
* Follow the principle of least privilege when creating Vault policies.

---

# Key Points

* Terraform frequently handles sensitive infrastructure credentials.
* Sensitive variables hide values from Terraform output.
* Secret management systems securely store and provide secrets.
* Environment variables keep credentials outside the codebase.
* Remote backends help protect state files.
* HashiCorp Vault is commonly used for secure secret management.
* AppRole authentication is the recommended method for Terraform automation.

---

# Remember

* **Never hardcode passwords, API keys, or cloud credentials.**
* **`sensitive = true` hides values but does not encrypt the state file.**
* **The Terraform state file may still contain sensitive data—always secure it.**
* **Use Vault or another secret manager for production environments.**
* **Role ID identifies the application; Secret ID authenticates it.**
* **Development mode (`vault server -dev`) is only for learning and should never be used in production.**
