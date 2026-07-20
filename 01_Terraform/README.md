# Terraform - Day 1 Notes

## Infrastructure as Code (IaC)

### What is IaC?

Infrastructure as Code (IaC) is the practice of managing and provisioning infrastructure using code instead of manual configuration.

Instead of creating servers, networks, databases, and other cloud resources manually through a cloud console, everything is defined in configuration files. This makes infrastructure consistent, repeatable, and easy to manage.

---

## Why IaC?

Before IaC, infrastructure management had several problems:

* Servers were configured manually, which often caused inconsistencies.
* Infrastructure changes were difficult to track because there was no version control.
* Teams relied heavily on documentation that became outdated quickly.
* Automation was mostly limited to simple scripts.
* Provisioning new environments was slow and required many manual steps.

IaC solves these problems by making infrastructure:

* Automated
* Repeatable
* Version controlled
* Consistent
* Faster to provision
* Easier to maintain

---

## Popular IaC Tools

| Tool                         | Cloud Support |
| ---------------------------- | ------------- |
| Terraform                    | Multi-cloud   |
| AWS CloudFormation           | AWS           |
| Azure Resource Manager (ARM) | Azure         |

---

# Why Terraform?

Terraform is one of the most popular IaC tools because it offers several advantages.

### 1. Multi-Cloud Support

Terraform works with multiple cloud providers using the same syntax.

Examples:

* AWS
* Azure
* Google Cloud
* VMware
* Kubernetes
* Many more

This avoids vendor lock-in.

---

### 2. Huge Ecosystem

Terraform provides:

* Thousands of providers
* Reusable modules
* Large community support

Many common infrastructures are already available as reusable modules.

---

### 3. Declarative Language

Terraform uses a **declarative approach**.

Instead of writing **how** to create infrastructure, I only describe **what** the final infrastructure should look like.

Terraform figures out the required steps automatically.

---

### 4. State Management

Terraform stores the current infrastructure in a **state file**.

The state helps Terraform compare:

* Current infrastructure
* Desired infrastructure

Then it performs only the required changes.

---

### 5. Plan Before Apply

Terraform allows previewing changes before making them.

Workflow:

```text
Write Code
      ↓
terraform plan
      ↓
Review Changes
      ↓
terraform apply
```

This reduces accidental infrastructure changes.

---

### 6. Strong Community

Terraform has:

* Excellent documentation
* Active community
* Plenty of examples and modules

Finding solutions is usually easy.

---

### 7. Easy Integration

Terraform integrates well with:

* Docker
* Kubernetes
* Jenkins
* Ansible
* GitHub Actions
* CI/CD pipelines

---

### 8. HCL (HashiCorp Configuration Language)

Terraform uses **HCL**, which is:

* Human readable
* Easy to learn
* Designed specifically for infrastructure

Example:

```hcl
resource "aws_instance" "example" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"
}
```

---

# Important Terraform Concepts

## Provider

A provider is a plugin that allows Terraform to communicate with a cloud or platform.

Examples:

* AWS
* Azure
* Google Cloud
* Kubernetes

Without a provider, Terraform cannot create resources.

---

## Resource

A resource is any infrastructure component managed by Terraform.

Examples:

* EC2 Instance
* S3 Bucket
* VPC
* Security Group
* Database

Resources are the main building blocks of Terraform.

---

## Module

A module is a reusable collection of Terraform files.

Benefits:

* Avoid duplicate code
* Improve maintainability
* Easy to reuse
* Easy to share

Modules can be:

* Custom modules
* Terraform Registry modules

---

## Configuration Files

Terraform configuration files usually have the **`.tf`** extension.

Common files:

| File               | Purpose                  |
| ------------------ | ------------------------ |
| `main.tf`          | Main infrastructure code |
| `variables.tf`     | Variable definitions     |
| `outputs.tf`       | Output values            |
| `terraform.tfvars` | Variable values          |

Terraform automatically reads all `.tf` files in the directory.

---

## Variables

Variables make Terraform configurations reusable.

Instead of hardcoding values, define them as variables and provide values later.

Example uses:

* Region
* Instance type
* AMI ID
* Project name

---

## Outputs

Outputs display useful information after deployment.

Examples:

* Public IP
* Instance ID
* DNS Name
* VPC ID

Outputs can also be used by other Terraform configurations.

---

## State File

Terraform stores infrastructure information inside:

```text
terraform.tfstate
```

The state file contains:

* Existing resources
* Resource IDs
* Metadata
* Current infrastructure state

Terraform compares this state with the configuration to determine required changes.

> **Remember:** Never edit the state file manually.

---

## Plan

Command:

```bash
terraform plan
```

Purpose:

* Compare desired state with current state.
* Preview all changes before applying them.

No infrastructure is created during this step.

---

## Apply

Command:

```bash
terraform apply
```

Purpose:

* Create resources
* Update resources
* Delete resources (if required)

Terraform executes the actions shown in the plan.

---

## Workspace

Workspaces allow managing multiple environments using the same configuration.

Examples:

* Development
* Testing
* Staging
* Production

Each workspace maintains its own state file.

---

## Remote Backend

By default, Terraform stores the state locally.

A **remote backend** stores the state remotely for better collaboration.

Common backends:

* Amazon S3
* Azure Blob Storage
* Terraform Cloud

Benefits:

* Team collaboration
* Better security
* Centralized state management
* State locking (depending on backend)

---

# Installing Terraform

Terraform can be installed on:

* Windows
* Linux
* macOS

Official download page:

[https://developer.hashicorp.com/terraform/downloads](https://developer.hashicorp.com/terraform/downloads)

### Alternative

GitHub Codespaces can also be used.

It provides:

* Ubuntu VM
* VS Code
* Free usage (limited hours)

---

# Setting Up Terraform for AWS

## Step 1: Install AWS CLI

Download and install AWS CLI.

AWS CLI is required so Terraform can authenticate with AWS.

---

## Step 2: Create an IAM User

Instead of using the root account, create an IAM user.

Required steps:

1. Open AWS Console.
2. Go to **IAM**.
3. Create a new user.
4. Enable **Programmatic Access**.
5. Attach the required permissions.

Minimum permission for EC2 practice:

```text
AmazonEC2FullAccess
```

Save the following credentials:

* Access Key ID
* Secret Access Key

These credentials will be used by Terraform.

---

## Step 3: Configure AWS CLI

Run:

```bash
aws configure
```

Enter:

```text
AWS Access Key ID:
AWS Secret Access Key:
Default region:
Default output format:
```

Example:

```text
AWS Access Key ID: ****************
AWS Secret Access Key: ****************
Default region: ap-south-1
Default output format: json
```

After configuration, Terraform automatically uses these credentials while communicating with AWS.

---

# Terraform Workflow

```text
Write Terraform Code
        ↓
terraform init
        ↓
terraform plan
        ↓
Review Changes
        ↓
terraform apply
        ↓
Infrastructure Created
```

---

# Key Points

* IaC means managing infrastructure using code.
* Terraform is cloud-agnostic and supports multiple providers.
* HCL is Terraform's configuration language.
* Providers connect Terraform to cloud platforms.
* Resources are the infrastructure components Terraform manages.
* Modules help reuse Terraform code.
* Variables increase flexibility.
* Outputs expose useful resource information.
* `terraform.tfstate` tracks infrastructure state.
* Always run `terraform plan` before `terraform apply`.
* Remote backends are preferred for team environments.

---

# Remember

* Terraform is **declarative**, not imperative.
* Never manually edit the `terraform.tfstate` file.
* Avoid using the AWS root account; always create an IAM user.
* Store the state remotely (e.g., S3) when working in teams.
* Always review the execution plan before applying changes.
* All `.tf` files in a directory together define the desired infrastructure state.
