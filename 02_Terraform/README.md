# Terraform - Day 2 Notes

## Providers

### What is a Provider?

A **Provider** is a plugin that allows Terraform to communicate with external APIs such as cloud platforms, SaaS services, and other infrastructure providers.

Without a provider, Terraform cannot create or manage any resources.

Some common providers are:

* AWS (`aws`)
* Azure (`azurerm`)
* Google Cloud (`google`)
* Kubernetes (`kubernetes`)
* OpenStack (`openstack`)
* VMware vSphere (`vsphere`)

---

## Basic Provider Example

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0123456789abcdef0"
  instance_type = "t2.micro"
}
```

### How it works

1. Terraform installs the required provider.
2. The provider authenticates with the cloud platform.
3. Terraform uses the provider's API to create and manage resources.

---

# Provider Configuration Methods

Terraform provides multiple ways to configure providers.

## 1. Configure in the Root Module (Most Common)

The provider block is placed in the root directory, making it available to all resources.

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0123456789abcdef0"
  instance_type = "t2.micro"
}
```

### When to use

* Small projects
* Single cloud provider
* Default choice

---

## 2. Configure in a Child Module

Useful when working with reusable modules.

```hcl
module "aws_vpc" {
  source = "./aws_vpc"

  providers = {
    aws = aws.us-west-2
  }
}

resource "aws_instance" "example" {
  ami           = "ami-0123456789abcdef0"
  instance_type = "t2.micro"

  depends_on = [module.aws_vpc]
}
```

### When to use

* Reusable modules
* Multiple regions
* Large projects

---

## 3. Configure Using `required_providers`

Used to specify exactly which provider and version Terraform should use.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.79"
    }
  }
}
```

### Why use it?

* Locks provider version
* Prevents unexpected upgrades
* Makes projects reproducible

---

# Multiple Providers

Terraform supports multiple providers within the same project.

Example:

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "azurerm" {
  subscription_id = "your-azure-subscription-id"
  client_id       = "your-azure-client-id"
  client_secret   = "your-azure-client-secret"
  tenant_id       = "your-azure-tenant-id"
}
```

Resources can then be created in different clouds.

```hcl
resource "aws_instance" "example" {
  ami           = "ami-0123456789abcdef0"
  instance_type = "t2.micro"
}

resource "azurerm_virtual_machine" "example" {
  name     = "example-vm"
  location = "eastus"
  size     = "Standard_A1"
}
```

### Use Case

One Terraform project can manage:

* AWS
* Azure
* GCP
* Kubernetes

at the same time.

---

# Provider Configuration

Always specify the required provider and its version.

```hcl
terraform {
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0, < 3.0"
    }

  }
}
```

### Why?

* Downloads the correct provider.
* Ensures compatibility.
* Prevents version conflicts.

---

# Variables

Variables make Terraform configurations reusable and flexible.

Instead of hardcoding values, define them once and pass different values whenever needed.

---

## Input Variables

Input variables receive values from outside the configuration.

Example:

```hcl
variable "example_var" {
  description = "An example input variable"
  type        = string
  default     = "default_value"
}
```

Using the variable:

```hcl
resource "example_resource" "example" {
  name = var.example_var
}
```

### Variable Components

| Field       | Purpose                |
| ----------- | ---------------------- |
| description | Explains the variable  |
| type        | Data type              |
| default     | Optional default value |

Common data types:

* string
* number
* bool
* list
* map
* object

---

## Output Variables

Outputs expose values after Terraform creates resources.

Example:

```hcl
output "example_output" {
  description = "An example output variable"
  value       = resource.example_resource.example.id
}
```

Outputs from a module can be accessed like this:

```hcl
module.module_name.output_name
```

Example:

```hcl
output "root_output" {
  value = module.example_module.example_output
}
```

---

# Variables Demo

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "EC2 AMI ID"
  type        = string
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
}

output "public_ip" {
  description = "Public IP address"
  value       = aws_instance.example_instance.public_ip
}
```

---

# Terraform `.tfvars`

A `.tfvars` file stores values for input variables.

Instead of hardcoding values inside `.tf` files, keep them in separate variable files.

Example:

```text
dev.tfvars
prod.tfvars
staging.tfvars
```

Benefits:

* Separates configuration from code.
* Reuses the same Terraform code for different environments.
* Keeps sensitive information outside the main code.
* Makes collaboration easier.

---

## Using a tfvars File

Run Terraform with:

```bash
terraform apply -var-file=dev.tfvars
```

Terraform automatically loads the values from the specified file.

---

# Conditional Expressions

Terraform supports conditional logic using the syntax:

```hcl
condition ? true_value : false_value
```

If the condition is true, Terraform returns the first value.

Otherwise, it returns the second value.

---

## Example 1 - Conditional Resource Creation

```hcl
resource "aws_instance" "example" {

  count = var.create_instance ? 1 : 0

  ami           = "ami-XXXXXXXXXXXXXXXXX"
  instance_type = "t2.micro"
}
```

If `create_instance = true`

→ One EC2 instance is created.

If `false`

→ No instance is created.

---

## Example 2 - Conditional Variable Assignment

```hcl
variable "environment" {
  default = "development"
}

variable "production_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "development_subnet_cidr" {
  default = "10.0.2.0/24"
}

resource "aws_security_group" "example" {

  name = "example-sg"

  ingress {

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = var.environment == "production"
      ? [var.production_subnet_cidr]
      : [var.development_subnet_cidr]
  }

}
```

Depending on the environment, Terraform automatically selects the correct subnet.

---

## Example 3 - Conditional Resource Configuration

```hcl
resource "aws_security_group" "example" {

  name = "example-sg"

  ingress {

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = var.enable_ssh
      ? ["0.0.0.0/0"]
      : []

  }

}
```

If `enable_ssh` is true,

SSH is allowed.

Otherwise,

No SSH rule is created.

---

# Built-in Functions

Terraform provides many built-in functions for working with strings, lists, maps, numbers, and expressions.

---

## 1. concat()

Combines multiple lists.

```hcl
output "combined_list" {
  value = concat(var.list1, var.list2)
}
```

---

## 2. element()

Returns the value at a given index.

```hcl
output "selected_element" {
  value = element(var.my_list, 1)
}
```

Returns:

```text
banana
```

---

## 3. length()

Returns the size of a list.

```hcl
output "list_length" {
  value = length(var.my_list)
}
```

Returns:

```text
3
```

---

## 4. map()

Creates a key-value map.

```hcl
output "my_map" {
  value = map(var.keys, var.values)
}
```

Returns:

```text
{
  name = "Alice"
  age  = 30
}
```

---

## 5. lookup()

Retrieves a value from a map using its key.

```hcl
output "value" {
  value = lookup(var.my_map, "name")
}
```

Returns:

```text
Alice
```

---

## 6. join()

Joins list elements into a string.

```hcl
output "joined_string" {
  value = join(", ", var.my_list)
}
```

Returns:

```text
apple, banana, cherry
```

---

# Key Points

* Providers allow Terraform to communicate with cloud APIs.
* Every resource belongs to a provider.
* `required_providers` is used to lock provider versions.
* A single Terraform project can use multiple providers.
* Input variables make code reusable.
* Output variables expose useful resource values.
* `.tfvars` files store variable values separately from code.
* Conditional expressions use `condition ? true_value : false_value`.
* Built-in functions simplify working with lists, strings, maps, and other data.

---

# Remember

* Always define provider versions using `required_providers`.
* Avoid hardcoding values; prefer variables.
* Keep secrets and environment-specific values in `.tfvars` files.
* Use conditional expressions to make configurations flexible.
* Functions can greatly reduce repetitive code and improve readability.
* Learn the commonly used functions (`concat`, `length`, `lookup`, `join`, `element`) since they appear frequently in real Terraform projects and interviews.
