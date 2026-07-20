# Terraform - Day 4 Notes

# Terraform State File

## What is a Terraform State File?

Terraform stores the current state of the infrastructure inside a **state file**, usually named:

```text
terraform.tfstate
```

It is a JSON-based file that contains information about every resource Terraform manages.

Terraform uses this file to compare:

* Desired infrastructure (Terraform code)
* Current infrastructure (State file)

Based on the comparison, Terraform decides what needs to be created, updated, or destroyed.

---

# Why is the State File Important?

Without the state file, Terraform would not know:

* Which resources already exist
* Resource IDs
* Dependencies
* Current configuration
* Metadata

Every `terraform plan` and `terraform apply` depends on the state file.

---

# What Does the State File Store?

The state file stores information like:

* Resource IDs
* Resource attributes
* Dependencies
* Metadata
* Current infrastructure state
* Outputs

Example:

```text
terraform.tfstate
│
├── EC2 Instance ID
├── Security Group ID
├── VPC ID
├── S3 Bucket ID
├── Output Values
└── Resource Metadata
```

---

# Advantages of Terraform State File

## 1. Resource Tracking

Terraform keeps track of every managed resource.

This allows Terraform to:

* Update existing resources
* Destroy resources safely
* Avoid creating duplicate resources

---

## 2. Plan Calculation

During:

```bash
terraform plan
```

Terraform compares:

* Desired configuration
* Current state

It then generates an execution plan showing exactly what will change.

---

## 3. Resource Metadata

The state file stores important metadata such as:

* Resource IDs
* Dependencies
* Attributes

Terraform uses this information while managing infrastructure.

---

## 4. Concurrency Control

When using remote state with locking, Terraform ensures that only one person can modify the infrastructure at a time.

This prevents:

* Conflicts
* Corrupted state
* Simultaneous updates

---

# Problems with Local State File

By default, Terraform stores the state locally.

Example:

```text
terraform.tfstate
```

This works well for learning but is not suitable for teams.

Problems:

* State exists only on one machine.
* Difficult to share.
* Easy to lose.
* No locking.
* Multiple users can overwrite each other's changes.

---

# Why NOT Store State in Git?

Storing `terraform.tfstate` in GitHub or any Version Control System (VCS) is a bad practice.

## 1. Security Risk

The state file may contain:

* AWS Access Keys
* Passwords
* Secrets
* Database credentials
* Sensitive resource information

Anyone with repository access could view this data.

---

## 2. Merge Conflicts

If multiple people update the state file simultaneously,

Git may create merge conflicts.

Terraform state should never be merged manually.

---

## 3. Versioning Problems

Since the state changes frequently,

committing every update makes version history noisy and difficult to manage.

---

# Remote Backend

Instead of storing the state locally, store it remotely.

Common remote backends:

* Amazon S3
* Terraform Cloud
* Azure Blob Storage
* Google Cloud Storage

The most common AWS setup is:

```text
S3 + DynamoDB
```

---

# Why Use an S3 Backend?

Benefits:

* Centralized state
* Team collaboration
* Better security
* Backup
* High availability
* Accessible from anywhere

---

# S3 Backend Configuration

```hcl
terraform {
  backend "s3" {

    bucket = "your-terraform-state-bucket"

    key = "path/to/terraform.tfstate"

    region = "us-east-1"

    encrypt = true

    dynamodb_table = "your-dynamodb-table"

  }
}
```

### Important Fields

| Field          | Purpose               |
| -------------- | --------------------- |
| bucket         | S3 bucket name        |
| key            | Path of state file    |
| region         | AWS region            |
| encrypt        | Encrypt state file    |
| dynamodb_table | Enables state locking |

---

# State Locking

State locking prevents multiple users from modifying the same infrastructure simultaneously.

Without locking:

```text
User A  ───────► Apply
                ▲
                │
User B  ───────► Apply
```

Both users may overwrite each other's changes.

---

With locking:

```text
User A
   │
   ▼
State Locked
   │
Terraform Apply
   │
State Unlocked

User B waits...
```

Only one Terraform operation can modify the state at a time.

---

# DynamoDB for State Locking

Terraform uses a DynamoDB table to lock the state.

While one user is running:

```bash
terraform apply
```

Other users cannot modify the state until the lock is released.

This keeps the infrastructure safe and consistent.

---

# Creating the DynamoDB Table

Using AWS CLI:

```bash
aws dynamodb create-table \
--table-name your-dynamodb-table \
--attribute-definitions AttributeName=LockID,AttributeType=S \
--key-schema AttributeName=LockID,KeyType=HASH \
--provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

---

# Steps to Configure a Remote Backend

## Step 1

Create an S3 bucket.

Example:

```text
your-terraform-state-bucket
```

---

## Step 2

Create a DynamoDB table.

Example:

```text
your-dynamodb-table
```

---

## Step 3

Configure the backend.

```hcl
terraform {
  backend "s3" {

    bucket = "your-terraform-state-bucket"

    key = "path/to/terraform.tfstate"

    region = "us-east-1"

    encrypt = true

    dynamodb_table = "your-dynamodb-table"

  }
}
```

---

## Step 4

Initialize Terraform.

```bash
terraform init
```

Terraform automatically migrates the state to the remote backend.

---

# Local vs Remote State

| Local State             | Remote State               |
| ----------------------- | -------------------------- |
| Stored on local machine | Stored in cloud            |
| No collaboration        | Team collaboration         |
| No locking              | State locking              |
| Easy to lose            | Highly available           |
| Less secure             | More secure                |
| Good for learning       | Recommended for production |

---

# Workflow

```text
Write Terraform Code
          │
          ▼
terraform init
          │
          ▼
Read State File
          │
          ▼
terraform plan
          │
          ▼
Compare Current State
          │
          ▼
terraform apply
          │
          ▼
Update State File
```

---

# Best Practices

* Never edit `terraform.tfstate` manually.
* Never commit the state file to Git.
* Always use a remote backend for team projects.
* Enable encryption for the S3 bucket.
* Use DynamoDB for state locking.
* Keep state files backed up.

---

# Key Points

* `terraform.tfstate` stores the current infrastructure state.
* Terraform compares the state file with the configuration to determine required changes.
* The state file stores resource IDs, metadata, dependencies, and outputs.
* Local state is suitable only for small or personal projects.
* Remote backends improve collaboration and security.
* S3 is commonly used to store Terraform state.
* DynamoDB provides state locking to prevent concurrent updates.

---

# Remember

* **Terraform depends on the state file.**
* **Never delete or manually modify the state file unless absolutely necessary.**
* **Never push `terraform.tfstate` to GitHub.**
* **S3 stores the state, DynamoDB locks the state.**
* **For production projects, always use a remote backend with state locking.**
