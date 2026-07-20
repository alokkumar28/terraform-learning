# Terraform - Day 6 Notes

# Terraform Workspaces

## What are Workspaces?

Terraform **Workspaces** allow the same Terraform configuration to manage multiple environments while keeping their state files separate.

Instead of creating separate Terraform projects for each environment, I can use workspaces to isolate environments like:

* Development (`dev`)
* Testing (`test`)
* Staging (`staging`)
* Production (`prod`)

Each workspace maintains its **own Terraform state**, even though the configuration files remain the same.

---

# Why Use Workspaces?

Without workspaces, managing multiple environments usually means creating multiple folders or copying the same Terraform code.

Example:

```text
Without Workspaces

terraform-dev/
terraform-test/
terraform-prod/
```

This results in:

* Duplicate code
* Difficult maintenance
* Higher chance of configuration drift

With workspaces:

```text
terraform-project/
│
├── main.tf
├── variables.tf
├── outputs.tf
└── Workspaces
     ├── dev
     ├── test
     └── prod
```

Only one Terraform configuration is maintained, while each environment has its own state.

---

# How Workspaces Work

Terraform uses a different state file for each workspace.

Example:

```text
Workspace: default
        │
        ▼
terraform.tfstate

Workspace: dev
        │
        ▼
terraform.tfstate.d/dev/

Workspace: prod
        │
        ▼
terraform.tfstate.d/prod/
```

The infrastructure code remains the same, but each workspace tracks its own resources.

---

# Default Workspace

Whenever a Terraform project is initialized, Terraform automatically creates a workspace called:

```text
default
```

Unless another workspace is selected, Terraform performs all operations in the **default** workspace.

---

# Workspace Commands

## List Workspaces

```bash
terraform workspace list
```

Example:

```text
* default
  dev
  test
  prod
```

The `*` indicates the currently active workspace.

---

## Create a Workspace

```bash
terraform workspace new dev
```

Example:

```bash
terraform workspace new staging
```

Terraform creates a new workspace along with its own state file.

---

## Switch Workspace

```bash
terraform workspace select dev
```

Example:

```bash
terraform workspace select prod
```

After switching, all Terraform commands operate on the selected workspace.

---

## Show Current Workspace

```bash
terraform workspace show
```

Example output:

```text
dev
```

---

## Delete a Workspace

```bash
terraform workspace delete dev
```

A workspace cannot be deleted while it is active.

First switch to another workspace:

```bash
terraform workspace select default
```

Then delete it.

---

# Typical Workflow

```text
terraform init
        │
        ▼
Create Workspace
(terraform workspace new dev)
        │
        ▼
Select Workspace
(terraform workspace select dev)
        │
        ▼
terraform plan
        │
        ▼
terraform apply
```

Each workspace maintains its own infrastructure state.

---

# Why Workspaces are Useful

## 1. Environment Isolation

Each environment has its own state file.

Example:

```text
Development
      │
terraform.tfstate

Production
      │
terraform.tfstate
```

Changes in one workspace do not affect another.

---

## 2. No Duplicate Code

One Terraform configuration can manage multiple environments.

Benefits:

* Less maintenance
* Cleaner project
* Easier updates

---

## 3. Separate Infrastructure

Even with the same code, each workspace creates independent resources.

Example:

```text
Workspace: dev

EC2 Instance
Database
VPC
```

```text
Workspace: prod

EC2 Instance
Database
VPC
```

Although the configuration is identical, the resources are completely separate.

---

## 4. Easier Testing

New infrastructure changes can be tested in the **dev** workspace before applying them to **production**.

Typical flow:

```text
Development
      │
Testing
      │
Staging
      │
Production
```

---

# Using Workspace Name in Terraform

Terraform provides a built-in variable:

```hcl
terraform.workspace
```

It returns the name of the currently selected workspace.

Example:

```hcl
resource "aws_instance" "example" {
  instance_type = terraform.workspace == "prod" ? "t3.medium" : "t2.micro"
}
```

In this example:

* Production workspace → `t3.medium`
* All other workspaces → `t2.micro`

This allows different configurations based on the active environment.

---

# Workspace Example

Suppose the current workspace is:

```text
dev
```

Running:

```bash
terraform apply
```

creates resources only for the **dev** environment.

After switching:

```bash
terraform workspace select prod
```

Running:

```bash
terraform apply
```

creates a completely separate production infrastructure.

Both environments use the same Terraform code but different state files.

---

# Workspace Directory Structure

Example:

```text
terraform-project/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfstate
└── terraform.tfstate.d/
    ├── dev/
    │   └── terraform.tfstate
    ├── test/
    │   └── terraform.tfstate
    └── prod/
        └── terraform.tfstate
```

Each workspace stores its own state independently.

---

# Advantages of Workspaces

| Advantage             | Benefit                                |
| --------------------- | -------------------------------------- |
| Environment isolation | Separate state for each environment    |
| Single codebase       | No duplicate Terraform code            |
| Easier testing        | Test safely before production          |
| Better organization   | Cleaner project structure              |
| Flexible deployments  | Different configurations per workspace |

---

# Limitations of Workspaces

* Workspaces separate **state**, not Terraform code.
* Large production systems often use separate Terraform projects instead of relying only on workspaces.
* Sensitive production environments may require completely independent backends and repositories.
* Workspaces are best suited when environments share the same infrastructure structure.

---

# Common Commands

| Command                             | Purpose                |
| ----------------------------------- | ---------------------- |
| `terraform workspace list`          | List all workspaces    |
| `terraform workspace new <name>`    | Create a workspace     |
| `terraform workspace select <name>` | Switch workspace       |
| `terraform workspace show`          | Show current workspace |
| `terraform workspace delete <name>` | Delete a workspace     |

---

# Key Points

* Workspaces allow multiple environments using the same Terraform code.
* Every workspace maintains its own state file.
* Terraform creates a **default** workspace automatically.
* Switching workspaces changes which infrastructure Terraform manages.
* `terraform.workspace` returns the current workspace name.
* Workspaces are useful for managing development, testing, staging, and production environments.

---

# Remember

* **Workspaces isolate state, not code.**
* **Never run `terraform apply` without checking the active workspace.**
* Use `terraform workspace show` to verify the current environment.
* Test changes in a non-production workspace before applying them to production.
* For large production infrastructures, separate backends or projects may be a better choice than relying solely on workspaces.
