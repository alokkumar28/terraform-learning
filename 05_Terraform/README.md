# Terraform - Day 5 Notes

# Provisioners

## What are Provisioners?

Provisioners are used to execute scripts or commands **after** a resource has been created (or before it is destroyed).

They help perform additional configuration that Terraform itself cannot manage directly.

Examples:

* Copy files
* Install software
* Run shell commands
* Configure servers

> **Note:** Provisioners should be used only when there is no better Terraform-native solution. They are considered a **last resort** because they are less predictable and harder to maintain.

---

# Types of Provisioners

Terraform provides three commonly used provisioners:

| Provisioner   | Runs Where?    | Purpose                   |
| ------------- | -------------- | ------------------------- |
| `file`        | Remote machine | Copy files or directories |
| `remote-exec` | Remote machine | Execute commands remotely |
| `local-exec`  | Local machine  | Execute commands locally  |

---

# 1. File Provisioner

## What is it?

The **file provisioner** copies files or directories from the local machine to a remote machine.

Useful for:

* Configuration files
* Shell scripts
* Application files
* Certificates

---

## Example

```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  provisioner "file" {

    source      = "local/path/to/localfile.txt"

    destination = "/path/on/remote/instance/file.txt"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
    }
  }
}
```

---

## Explanation

Terraform:

1. Creates the EC2 instance.
2. Connects using SSH.
3. Copies:

```text
local/path/to/localfile.txt
```

to

```text
/path/on/remote/instance/file.txt
```

---

## Connection Block

The connection block tells Terraform how to connect to the remote machine.

```hcl
connection {
  type        = "ssh"
  user        = "ec2-user"
  private_key = file("~/.ssh/id_rsa")
}
```

### Important Fields

| Field         | Purpose                            |
| ------------- | ---------------------------------- |
| `type`        | Connection type (`ssh` or `winrm`) |
| `user`        | Remote login user                  |
| `private_key` | SSH private key                    |

---

# 2. Remote-Exec Provisioner

## What is it?

The **remote-exec** provisioner runs shell commands on the remote machine after it is created.

Useful for:

* Installing packages
* Updating the system
* Starting services
* Running setup scripts

---

## Example

```hcl
resource "aws_instance" "example" {

  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  provisioner "remote-exec" {

    inline = [

      "sudo yum update -y",

      "sudo yum install -y httpd",

      "sudo systemctl start httpd"

    ]

    connection {

      type        = "ssh"

      user        = "ec2-user"

      private_key = file("~/.ssh/id_rsa")

      host        = aws_instance.example.public_ip

    }

  }

}
```

---

## What Happens?

Terraform:

1. Creates the EC2 instance.
2. Connects via SSH.
3. Executes:

```bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
```

The result is an EC2 instance with the Apache HTTP Server installed and running.

---

## Inline Commands

Commands are written inside the `inline` list.

Example:

```hcl
inline = [
  "command1",
  "command2",
  "command3"
]
```

They execute in the same order.

---

# 3. Local-Exec Provisioner

## What is it?

The **local-exec** provisioner executes commands **on the local machine** where Terraform is running.

It does **not** connect to the remote resource.

Useful for:

* Running scripts
* Logging
* Notifications
* Calling external tools
* Local automation

---

## Example

```hcl
resource "null_resource" "example" {

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {

    command = "echo 'This is a local command'"

  }

}
```

---

## What Happens?

Terraform executes:

```bash
echo "This is a local command"
```

on the **local computer**, not on the EC2 instance.

---

# Why Use `null_resource`?

A `null_resource` doesn't create any infrastructure.

It is commonly used when only provisioners or custom automation need to run.

---

# Triggers

```hcl
triggers = {
  always_run = timestamp()
}
```

The `timestamp()` function changes every time Terraform runs.

Because the value changes, Terraform treats the resource as modified and executes the provisioner every time.

Without this trigger, `local-exec` would run only when the resource is first created.

---

# Provisioner Comparison

| Provisioner   | Executes On    | Common Use Cases                       |
| ------------- | -------------- | -------------------------------------- |
| `file`        | Remote machine | Copy files                             |
| `remote-exec` | Remote machine | Install software, configure servers    |
| `local-exec`  | Local machine  | Run local scripts, logging, automation |

---

# Typical Workflow

```text
Terraform Apply
        │
        ▼
Create Resource
        │
        ▼
Provisioner Runs
        │
        ├──────────────┐
        │              │
        ▼              ▼
file         remote-exec
(Copy)       (Run commands)
        │
        ▼
local-exec
(Local machine only)
```

---

# Common Use Cases

### File

* Copy configuration files
* Upload scripts
* Deploy application files

---

### Remote-Exec

* Install Apache/Nginx
* Install Docker
* Configure services
* Update packages
* Start applications

---

### Local-Exec

* Print logs
* Send notifications
* Run shell scripts
* Execute local automation
* Trigger external tools

---

# Key Points

* Provisioners execute actions after resource creation.
* `file` copies files to a remote machine.
* `remote-exec` runs commands on a remote machine.
* `local-exec` runs commands on the local machine.
* SSH connection details are specified using a `connection` block.
* `null_resource` is commonly used with `local-exec`.
* `timestamp()` can be used to force a provisioner to run on every apply.

---

# Remember

* Provisioners are considered a **last resort**; prefer Terraform-native resources and cloud-init/user data whenever possible.
* `file` only transfers files—it does not execute them.
* `remote-exec` requires network connectivity and valid SSH/WinRM credentials.
* `local-exec` never runs on the remote server; it always executes on the machine running Terraform.
* The `connection` block is required for `file` and `remote-exec` when connecting over SSH or WinRM.
