## Variables and Outputs

- [Collection types](https://www.terraform.io/language/expressions/type-constraints#collection-types)

Variables types: 

![](https://i.imgur.com/vv1C3LU.png)

#### Outputs
- [Output Variables Documentation](https://www.terraform.io/language/values/outputs)
  
![](https://i.imgur.com/UhYd1Mf.png)


## Provisioners

- [Official Documentation](https://www.terraform.io/language/resources/provisioners/syntax)


```json
resource "null_resource" "mk" {
  provisioner "local-exec" {
    command = "echo '0' > status.txt"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "echo '1' > status.txt"
  }
}
```

### Terraform state commands 

![](https://i.imgur.com/jdNkRES.png)

- [Official Documentation](https://www.terraform.io/cli/commands/state#remote-state)

```json
# Configure the Docker provider
provider "docker" {}

#Image to be used by container
resource "docker_image" "terraform-centos" {
  name         = "centos:7"
  keep_locally = true
}

# Create a container
resource "docker_container" "centos" {
  image   = docker_image.terraform-centos.latest
  name    = "terraform-centos"
  start   = true
  command = ["/bin/sleep", "500"]
}
```

### Terraform Modules

- [Official Documentation](https://www.terraform.io/language/modules)

### Terraform Built-in-function

- [Official Documentation](https://www.terraform.io/language/functions)

### Terraform fmt, taint, and import Commands

- [Command:: fmt](https://www.terraform.io/cli/commands/fmt)
- [Command:: taint](https://www.terraform.io/cli/commands/taint)
- [Command:: import](https://www.terraform.io/cli/commands/import)
- [Terraform Settings](https://www.terraform.io/language/settings)

### Terraform Workspaces
Terraform configuration always has a default workspace associated with it. This default workspace always exists regardless of whether or not you create new workspaces locally and it cannot be deleted.


The command terraform workspace select <workspace-name> selects or switches to an existing workspace of your choice, using the name you have provided.


ECS
```json
provider "aws" {
  region = terraform.workspace == "default" ? "us-east-1" : "us-west-2"
}

#Get Linux AMI ID using SSM Parameter endpoint in us-east-1
data "aws_ssm_parameter" "linuxAmi" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#Create and bootstrap EC2 in us-east-1
resource "aws_instance" "ec2-vm" {
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.subnet.id
  tags = {
    Name = "${terraform.workspace}-ec2"
  }
}
```


Network
```json
#Create VPC in us-east-1
resource "aws_vpc" "vpc_master" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${terraform.workspace}-vpc"
  }

}

#Get all available AZ's in VPC for master region
data "aws_availability_zones" "azs" {
  state = "available"
}

#Create subnet # 1 in us-east-1
resource "aws_subnet" "subnet" {
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name = "${terraform.workspace}-subnet"
  }
}


#Create SG for allowing TCP/22 from anywhere, THIS IS FOR TESTING ONLY
resource "aws_security_group" "sg" {
  name        = "${terraform.workspace}-sg"
  description = "Allow TCP/22"
  vpc_id      = aws_vpc.vpc_master.id
  ingress {
    description = "Allow 22 from our public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${terraform.workspace}-securitygroup"
  }
}
```

### Debugging Terraform


 You can set TF_LOG to the TRACE, DEBUG, INFO, WARN, or ERROR log level to change the verbosity of the log. TRACE is the default log level, and it is the most verbose.
```bash
export TF_LOG=TRACE
export TF_LOG_PATH=terraform.log

```


### Terraform Vault Provider for Injecting Secrets Securely

![Vault structure](https://i.imgur.com/GGcZhIc.png)

### Destroy and apply specific resources 

```bash
terraform apply --target github_repository_file.github_repository_file_readme
terraform destroy --target github_repository_file.github_repository_file_readme
```

###  How to Manage Terraform State

 As you were using Terraform to create and update resources, you might have noticed that every time you ran terraform plan or terraform apply, Terraform was able to find the resources it created previously and update them accordingly. But how did Terraform know which resources it was supposed to manage? You could have all sorts of infrastructure in your AWS account, deployed through a variety of mechanisms (some manually, some via Terraform, some via the CLI), so how does Terraform know which infrastructure it’s responsible for?

 Every time you run Terraform, it records information about what infrastructure it created in a Terraform state file. By default, when you run Terraform in the folder /foo/bar, Terraform creates the file /foo/bar/terraform.tfstate. This file contains a custom JSON format that records a mapping from the Terraform resources in your configuration files to the representation of those resources in the real world. 

> The state file format is a private API that is meant only for internal use within Terraform. You should never edit the Terraform state files by hand or write code that reads them directly.
> 
> If for some reason you need to manipulate the state file—which should be a relatively rare occurrence—use the terraform import or terraform state commands


If you’re using Terraform for a personal project, storing state in a single terraform.tfstate file that lives locally on your computer works just fine. But if you want to use Terraform as a team on a real product, you run into several problems:

**Shared storage for state files**
To be able to use Terraform to update your infrastructure, each of your team members needs access to the same Terraform state files. That means you need to store those files in a shared location.

**Locking state files**
As soon as data is shared, you run into a new problem: locking. Without locking, if two team members are running Terraform at the same time, you can run into race conditions as multiple Terraform processes make concurrent updates to the state files, leading to conflicts, data loss, and state file corruption.

**Isolating state files**
When making changes to your infrastructure, it’s a best practice to isolate different environments. For example, when making a change in a testing or staging environment, you want to be sure that there is no way you can accidentally break production. But how can you isolate your changes if all of your infrastructure is defined in the same Terraform state file?


### Arguments for specifying provider

![provider](https://i.imgur.com/hBfVE7Y.png)


#### Shared Storage for State Files
The most common technique for allowing multiple team members to access a common set of files is to put them in version control (e.g., Git). Although you should definitely store your Terraform code in version control, storing Terraform state in version control is a bad idea for the following reasons:

**Manual error**
It’s too easy to forget to pull down the latest changes from version control before running Terraform or to push your latest changes to version control after running Terraform. It’s just a matter of time before someone on your team runs Terraform with out-of-date state files and, as a result, accidentally rolls back or duplicates previous deployments.

**Locking**
Most version control systems do not provide any form of locking that would prevent two team members from running terraform apply on the same state file at the same time.

**Secrets**
All data in Terraform state files is stored in plain text. This is a problem because certain Terraform resources need to store sensitive data. For example, if you use the aws_db_instance resource to create a database, Terraform will store the username and password for the database in a state file in plain text, and you shouldn’t store plain text secrets in version control.

Instead of using version control, the best way to manage shared storage for state files is to use Terraform’s built-in support for remote backends. A Terraform backend determines how Terraform loads and stores state. The default backend, which you’ve been using this entire time, is the local backend, which stores the state file on your local disk. Remote backends allow you to store the state file in a remote, shared store. A number of remote backends are supported, including Amazon S3, Azure Storage, Google Cloud Storage, and HashiCorp’s Terraform Cloud and Terraform Enterprise.

### Backend
```json
terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "state-terraform-s3-resource"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-2"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

Let’s go through these settings one at a time:

**bucket**
The name of the S3 bucket to use. Make sure to replace this with the name of the S3 bucket you created earlier.

**key**
The filepath within the S3 bucket where the Terraform state file should be written. You’ll see a little later on why the preceding example code sets this to global/s3/terraform.tfstate.

**region**
The AWS region where the S3 bucket lives. Make sure to replace this with the region of the S3 bucket you created earlier.

**dynamodb_table**
The DynamoDB table to use for locking. Make sure to replace this with the name of the DynamoDB table you created earlier.

**encrypt**
Setting this to true ensures that your Terraform state will be encrypted on disk when stored in S3. We already enabled default encryption in the S3 bucket itself, so this is here as a second layer to ensure that the data is always encrypted.

### Limitations with Terraform’s Backends

Terraform’s backends have a few limitations and gotchas that you need to be aware of. The first limitation is the chicken-and-egg situation of using Terraform to create the S3 bucket where you want to store your Terraform state. To make this work, you had to use a two-step process:

1. Write Terraform code to create the S3 bucket and DynamoDB table, and deploy that code with a local backend.

2. Go back to the Terraform code, add a remote backend configuration to it to use the newly created S3 bucket and DynamoDB table, and run terraform init to copy your local state to S3.

If you ever wanted to delete the S3 bucket and DynamoDB table, you’d have to do this two-step process in reverse:

1. Go to the Terraform code, remove the backend configuration, and rerun terraform init to copy the Terraform state back to your local disk.

2. Run terraform destroy to delete the S3 bucket and DynamoDB table.

This two-step process is a bit awkward, but the good news is that you can share a single S3 bucket and DynamoDB table across all of your Terraform code, so you’ll probably only need to do it once (or once per AWS account if you have multiple accounts). After the S3 bucket exists, in the rest of your Terraform code, you can specify the backend configuration right from the start without any extra steps.

The second limitation is more painful: the backend block in Terraform does not allow you to use any variables or references. The following code will not work:

```json
# This will NOT work. Variables aren't allowed in a backend configuration.
terraform {
  backend "s3" {
    bucket         = var.bucket
    region         = var.region
    dynamodb_table = var.dynamodb_table
    key            = "example/terraform.tfstate"
    encrypt        = true
  }
}
```

This means that you need to manually copy and paste the S3 bucket name, region, DynamoDB table name, etc., into every one of your Terraform modules (you’ll learn all about Terraform modules in Chapters 4 and 8; for now, it’s enough to understand that modules are a way to organize and reuse Terraform code and that real-world Terraform code typically consists of many small modules). Even worse, you must very carefully not copy and paste the key value but ensure a unique key for every Terraform module you deploy so that you don’t accidentally overwrite the state of some other module! Having to do lots of copy-and-pastes and lots of manual changes is error prone, especially if you need to deploy and manage many Terraform modules across many environments.

One option for reducing copy-and-paste is to use partial configurations, where you omit certain parameters from the backend configuration in your Terraform code and instead pass those in via -backend-config command-line arguments when calling terraform init. For example, you could extract the repeated backend arguments, such as bucket and region, into a separate file called backend.hcl:


Chapter 3. How to Manage Terraform State
In Chapter 2, as you were using Terraform to create and update resources, you might have noticed that every time you ran terraform plan or terraform apply, Terraform was able to find the resources it created previously and update them accordingly. But how did Terraform know which resources it was supposed to manage? You could have all sorts of infrastructure in your AWS account, deployed through a variety of mechanisms (some manually, some via Terraform, some via the CLI), so how does Terraform know which infrastructure it’s responsible for?

In this chapter, you’re going to see how Terraform tracks the state of your infrastructure and the impact that has on file layout, isolation, and locking in a Terraform project. Here are the key topics I’ll go over:

What is Terraform state?

Shared storage for state files

Limitations with Terraform’s backends

State file isolation

Isolation via workspaces

Isolation via file layout

The terraform_remote_state data source

EXAMPLE CODE
As a reminder, you can find all of the code examples in the book on GitHub.

What Is Terraform State?
Every time you run Terraform, it records information about what infrastructure it created in a Terraform state file. By default, when you run Terraform in the folder /foo/bar, Terraform creates the file /foo/bar/terraform.tfstate. This file contains a custom JSON format that records a mapping from the Terraform resources in your configuration files to the representation of those resources in the real world. For example, let’s say your Terraform configuration contained the following:

resource "aws_instance" "example" {
  ami           = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
}
After running terraform apply, here is a small snippet of the contents of the terraform.tfstate file (truncated for readability):

{
  "version": 4,
  "terraform_version": "1.2.3",
  "serial": 1,
  "lineage": "86545604-7463-4aa5-e9e8-a2a221de98d2",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "aws_instance",
      "name": "example",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 1,
          "attributes": {
            "ami": "ami-0fb653ca2d3203ac1",
            "availability_zone": "us-east-2b",
            "id": "i-0bc4bbe5b84387543",
            "instance_state": "running",
            "instance_type": "t2.micro",
            "(...)": "(truncated)"
          }
        }
      ]
    }
  ]
}
Using this JSON format, Terraform knows that a resource with type aws_instance and name example corresponds to an EC2 Instance in your AWS account with ID i-0bc4bbe5b84387543. Every time you run Terraform, it can fetch the latest status of this EC2 Instance from AWS and compare that to what’s in your Terraform configurations to determine what changes need to be applied. In other words, the output of the plan command is a diff between the code on your computer and the infrastructure deployed in the real world, as discovered via IDs in the state file.

THE STATE FILE IS A PRIVATE API
The state file format is a private API that is meant only for internal use within Terraform. You should never edit the Terraform state files by hand or write code that reads them directly.

If for some reason you need to manipulate the state file—which should be a relatively rare occurrence—use the terraform import or terraform state commands (you’ll see examples of both in Chapter 5).

If you’re using Terraform for a personal project, storing state in a single terraform.tfstate file that lives locally on your computer works just fine. But if you want to use Terraform as a team on a real product, you run into several problems:

Shared storage for state files
To be able to use Terraform to update your infrastructure, each of your team members needs access to the same Terraform state files. That means you need to store those files in a shared location.

Locking state files
As soon as data is shared, you run into a new problem: locking. Without locking, if two team members are running Terraform at the same time, you can run into race conditions as multiple Terraform processes make concurrent updates to the state files, leading to conflicts, data loss, and state file corruption.

Isolating state files
When making changes to your infrastructure, it’s a best practice to isolate different environments. For example, when making a change in a testing or staging environment, you want to be sure that there is no way you can accidentally break production. But how can you isolate your changes if all of your infrastructure is defined in the same Terraform state file?

In the following sections, I’ll dive into each of these problems and show you how to solve them.

Shared Storage for State Files
The most common technique for allowing multiple team members to access a common set of files is to put them in version control (e.g., Git). Although you should definitely store your Terraform code in version control, storing Terraform state in version control is a bad idea for the following reasons:

Manual error
It’s too easy to forget to pull down the latest changes from version control before running Terraform or to push your latest changes to version control after running Terraform. It’s just a matter of time before someone on your team runs Terraform with out-of-date state files and, as a result, accidentally rolls back or duplicates previous deployments.

Locking
Most version control systems do not provide any form of locking that would prevent two team members from running terraform apply on the same state file at the same time.

Secrets
All data in Terraform state files is stored in plain text. This is a problem because certain Terraform resources need to store sensitive data. For example, if you use the aws_db_instance resource to create a database, Terraform will store the username and password for the database in a state file in plain text, and you shouldn’t store plain text secrets in version control.

Instead of using version control, the best way to manage shared storage for state files is to use Terraform’s built-in support for remote backends. A Terraform backend determines how Terraform loads and stores state. The default backend, which you’ve been using this entire time, is the local backend, which stores the state file on your local disk. Remote backends allow you to store the state file in a remote, shared store. A number of remote backends are supported, including Amazon S3, Azure Storage, Google Cloud Storage, and HashiCorp’s Terraform Cloud and Terraform Enterprise.

Remote backends solve the three issues just listed:

Manual error
After you configure a remote backend, Terraform will automatically load the state file from that backend every time you run plan or apply, and it’ll automatically store the state file in that backend after each apply, so there’s no chance of manual error.

Locking
Most of the remote backends natively support locking. To run terraform apply, Terraform will automatically acquire a lock; if someone else is already running apply, they will already have the lock, and you will have to wait. You can run apply with the -lock-timeout=<TIME> parameter to instruct Terraform to wait up to TIME for a lock to be released (e.g., -lock-timeout=10m will wait for 10 minutes).

Secrets
Most of the remote backends natively support encryption in transit and encryption at rest of the state file. Moreover, those backends usually expose ways to configure access permissions (e.g., using IAM policies with an Amazon S3 bucket), so you can control who has access to your state files and the secrets they might contain. It would be better still if Terraform natively supported encrypting secrets within the state file, but these remote backends reduce most of the security concerns, given that at least the state file isn’t stored in plain text on disk anywhere.

If you’re using Terraform with AWS, Amazon S3 (Simple Storage Service), which is Amazon’s managed file store, is typically your best bet as a remote backend for the following reasons:

It’s a managed service, so you don’t need to deploy and manage extra infrastructure to use it.

It’s designed for 99.999999999% durability and 99.99% availability, which means you don’t need to worry too much about data loss or outages.1

It supports encryption, which reduces worries about storing sensitive data in state files. You still have to be very careful who on your team can access the S3 bucket, but at least the data will be encrypted at rest (Amazon S3 supports server-side encryption using AES-256) and in transit (Terraform uses TLS when talking to Amazon S3).

It supports locking via DynamoDB. (More on this later.)

It supports versioning, so every revision of your state file is stored, and you can roll back to an older version if something goes wrong.

It’s inexpensive, with most Terraform usage easily fitting into the AWS Free Tier.2

To enable remote state storage with Amazon S3, the first step is to create an S3 bucket. Create a main.tf file in a new folder (it should be a different folder from where you store the configurations from Chapter 2), and at the top of the file, specify AWS as the provider:

provider "aws" {
  region = "us-east-2"
}
Next, create an S3 bucket by using the aws_s3_bucket resource:

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-up-and-running-state"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
}
This code sets the following arguments:

bucket
This is the name of the S3 bucket. Note that S3 bucket names must be globally unique among all AWS customers. Therefore, you will need to change the bucket parameter from "terraform-up-and-running-state" (which I already created) to your own name. Make sure to remember this name and take note of what AWS region you’re using because you’ll need both pieces of information again a little later on.

prevent_destroy
prevent_destroy is the second lifecycle setting you’ve seen (the first was create_before_destroy in Chapter 2). When you set prevent_destroy to true on a resource, any attempt to delete that resource (e.g., by running terraform destroy) will cause Terraform to exit with an error. This is a good way to prevent accidental deletion of an important resource, such as this S3 bucket, which will store all of your Terraform state. Of course, if you really mean to delete it, you can just comment that setting out.

Let’s now add several extra layers of protection to this S3 bucket.

First, use the aws_s3_bucket_versioning resource to enable versioning on the S3 bucket so that every update to a file in the bucket actually creates a new version of that file. This allows you to see older versions of the file and revert to those older versions at any time, which can be a useful fallback mechanism if something goes wrong:

# Enable versioning so you can see the full revision history of your
# state files
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}
Second, use the aws_s3_bucket_server_side_encryption_configuration resource to turn server-side encryption on by default for all data written to this S3 bucket. This ensures that your state files, and any secrets they might contain, are always encrypted on disk when stored in S3:

# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
Third, use the aws_s3_bucket_public_access_block resource to block all public access to the S3 bucket. S3 buckets are private by default, but as they are often used to serve static content—e.g., images, fonts, CSS, JS, HTML—it is possible, even easy, to make the buckets public. Since your Terraform state files may contain sensitive data and secrets, it’s worth adding this extra layer of protection to ensure no one on your team can ever accidentally make this S3 bucket public:

# Explicitly block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
Next, you need to create a DynamoDB table to use for locking. DynamoDB is Amazon’s distributed key-value store. It supports strongly consistent reads and conditional writes, which are all the ingredients you need for a distributed lock system. Moreover, it’s completely managed, so you don’t have any infrastructure to run yourself, and it’s inexpensive, with most Terraform usage easily fitting into the AWS Free Tier.3

To use DynamoDB for locking with Terraform, you must create a DynamoDB table that has a primary key called LockID (with this exact spelling and capitalization). You can create such a table using the aws_dynamodb_table resource:

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
Run terraform init to download the provider code, and then run terraform apply to deploy. After everything is deployed, you will have an S3 bucket and DynamoDB table, but your Terraform state will still be stored locally. To configure Terraform to store the state in your S3 bucket (with encryption and locking), you need to add a backend configuration to your Terraform code. This is configuration for Terraform itself, so it resides within a terraform block and has the following syntax:

terraform {
  backend "<BACKEND_NAME>" {
    [CONFIG...]
  }
}
where BACKEND_NAME is the name of the backend you want to use (e.g., "s3") and CONFIG consists of one or more arguments that are specific to that backend (e.g., the name of the S3 bucket to use). Here’s what the backend configuration looks like for an S3 bucket:

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "terraform-up-and-running-state"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-2"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}
Let’s go through these settings one at a time:

bucket
The name of the S3 bucket to use. Make sure to replace this with the name of the S3 bucket you created earlier.

key
The filepath within the S3 bucket where the Terraform state file should be written. You’ll see a little later on why the preceding example code sets this to global/s3/terraform.tfstate.

region
The AWS region where the S3 bucket lives. Make sure to replace this with the region of the S3 bucket you created earlier.

dynamodb_table
The DynamoDB table to use for locking. Make sure to replace this with the name of the DynamoDB table you created earlier.

encrypt
Setting this to true ensures that your Terraform state will be encrypted on disk when stored in S3. We already enabled default encryption in the S3 bucket itself, so this is here as a second layer to ensure that the data is always encrypted.

To instruct Terraform to store your state file in this S3 bucket, you’re going to use the terraform init command again. This command not only can download provider code, but also configure your Terraform backend (and you’ll see yet another use later on, too). Moreover, the init command is idempotent, so it’s safe to run it multiple times:

$ terraform init

Initializing the backend...
Acquiring state lock. This may take a few moments...
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend
  to the newly configured "s3" backend. No existing state was found in the
  newly configured "s3" backend. Do you want to copy this state to the new
  "s3" backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value:
Terraform will automatically detect that you already have a state file locally and prompt you to copy it to the new S3 backend. If you type yes, you should see the following:

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.
After running this command, your Terraform state will be stored in the S3 bucket. You can check this by heading over to the S3 Management Console in your browser and clicking your bucket. You should see something similar to Figure 3-1.

Terraform state file stored in Amazon S3
Figure 3-1. You can use the AWS Console to see how your state file is stored in an S3 bucket.
With this backend enabled, Terraform will automatically pull the latest state from this S3 bucket before running a command and automatically push the latest state to the S3 bucket after running a command. To see this in action, add the following output variables:

output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}
These variables will print out the Amazon Resource Name (ARN) of your S3 bucket and the name of your DynamoDB table. Run terraform apply to see it:

$ terraform apply

(...)

Acquiring state lock. This may take a few moments...

aws_dynamodb_table.terraform_locks: Refreshing state...
aws_s3_bucket.terraform_state: Refreshing state...

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Releasing state lock. This may take a few moments...

Outputs:

dynamodb_table_name = "terraform-up-and-running-locks"
s3_bucket_arn = "arn:aws:s3:::terraform-up-and-running-state"
Note how Terraform is now acquiring a lock before running apply and releasing the lock after!

Now, head over to the S3 console again, refresh the page, and click the gray Show button next to Versions. You should now see several versions of your terraform.tfstate file in the S3 bucket, as shown in Figure 3-2.

Multiple versions of the Terraform state file in S3
Figure 3-2. If you enable versioning for your S3 bucket, every change to the state file will be stored as a separate version.
This means that Terraform is automatically pushing and pulling state data to and from S3, and S3 is storing every revision of the state file, which can be useful for debugging and rolling back to older versions if something goes wrong.

Limitations with Terraform’s Backends
Terraform’s backends have a few limitations and gotchas that you need to be aware of. The first limitation is the chicken-and-egg situation of using Terraform to create the S3 bucket where you want to store your Terraform state. To make this work, you had to use a two-step process:

Write Terraform code to create the S3 bucket and DynamoDB table, and deploy that code with a local backend.

Go back to the Terraform code, add a remote backend configuration to it to use the newly created S3 bucket and DynamoDB table, and run terraform init to copy your local state to S3.

If you ever wanted to delete the S3 bucket and DynamoDB table, you’d have to do this two-step process in reverse:

Go to the Terraform code, remove the backend configuration, and rerun terraform init to copy the Terraform state back to your local disk.

Run terraform destroy to delete the S3 bucket and DynamoDB table.

This two-step process is a bit awkward, but the good news is that you can share a single S3 bucket and DynamoDB table across all of your Terraform code, so you’ll probably only need to do it once (or once per AWS account if you have multiple accounts). After the S3 bucket exists, in the rest of your Terraform code, you can specify the backend configuration right from the start without any extra steps.

The second limitation is more painful: the backend block in Terraform does not allow you to use any variables or references. The following code will not work:
```json
# This will NOT work. Variables aren't allowed in a backend configuration.
terraform {
  backend "s3" {
    bucket         = var.bucket
    region         = var.region
    dynamodb_table = var.dynamodb_table
    key            = "example/terraform.tfstate"
    encrypt        = true
  }
}
```
This means that you need to manually copy and paste the S3 bucket name, region, DynamoDB table name, etc., into every one of your Terraform modules (you’ll learn all about Terraform modules in Chapters 4 and 8; for now, it’s enough to understand that modules are a way to organize and reuse Terraform code and that real-world Terraform code typically consists of many small modules). Even worse, you must very carefully not copy and paste the key value but ensure a unique key for every Terraform module you deploy so that you don’t accidentally overwrite the state of some other module! Having to do lots of copy-and-pastes and lots of manual changes is error prone, especially if you need to deploy and manage many Terraform modules across many environments.

One option for reducing copy-and-paste is to use partial configurations, where you omit certain parameters from the backend configuration in your Terraform code and instead pass those in via -backend-config command-line arguments when calling terraform init. For example, you could extract the repeated backend arguments, such as bucket and region, into a separate file called backend.hcl:

```json
# backend.hcl
bucket         = "terraform-up-and-running-state"
region         = "us-east-2"
dynamodb_table = "terraform-up-and-running-locks"
encrypt        = true
```
Only the key parameter remains in the Terraform code, since you still need to set a different key value for each module:

```json
# Partial configuration. The other settings (e.g., bucket, region) will be
# passed in from a file via -backend-config arguments to 'terraform init'
terraform {
  backend "s3" {
    key = "example/terraform.tfstate"
  }
}
```
To put all your partial configurations together, run terraform init with the -backend-config argument:

```bash
$ terraform init -backend-config=backend.hcl
```

Another option for reducing copy-and-paste is to use Terragrunt, an open source tool that tries to fill in a few gaps in Terraform. [Terragrunt](https://terragrunt.gruntwork.io/) can help you keep your entire backend configuration DRY (Don’t Repeat Yourself) by defining all the basic backend settings (bucket name, region, DynamoDB table name) in one file and automatically setting the key argument to the relative folder path of the module.

### State File Isolation
With a remote backend and locking, collaboration is no longer a problem. However, there is still one more problem remaining: isolation. When you first start using Terraform, you might be tempted to define all of your infrastructure in a single Terraform file or a single set of Terraform files in one folder. The problem with this approach is that all of your Terraform state is now stored in a single file, too, and a mistake anywhere could break everything.

For example, while trying to deploy a new version of your app in staging, you might break the app in production. Or, worse yet, you might corrupt your entire state file, either because you didn’t use locking or due to a rare Terraform bug, and now all of your infrastructure in all environments is broken.4

The whole point of having separate environments is that they are isolated from one another, so if you are managing all the environments from a single set of Terraform configurations, you are breaking that isolation. Just as a ship has bulkheads that act as barriers to prevent a leak in one part of the ship from immediately flooding all the others, you should have “bulkheads” built into your Terraform design,

 instead of defining all your environments in a single set of Terraform configurations (top), you want to define each environment in a separate set of configurations (bottom), so a problem in one environment is completely isolated from the others. There are two ways you could isolate state files:

_Isolation via workspaces_
Useful for quick, isolated tests on the same configuration

_Isolation via file layout_
Useful for production use cases for which you need strong separation between environments

Let’s dive into each of these in the next two sections.

Terraform workspaces allow you to store your Terraform state in multiple, separate, named workspaces. Terraform starts with a single workspace called “default,” and if you never explicitly specify a workspace, the default workspace is the one you’ll use the entire time. To create a new workspace or switch between workspaces, you use the terraform workspace commands. Let’s experiment with workspaces on some Terraform code that deploys a single EC2 Instance:

Configure a backend for this Instance using the S3 bucket and DynamoDB table you created earlier in the chapter but with the key set to workspaces-example/​terraform.tfstate:

```json
terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "terraform-up-and-running-state"
    key            = "workspaces-example/terraform.tfstate"
    region         = "us-east-2"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}
```

Let’s create a new workspace called “example1” using the terraform workspace new command:

```bash
$ terraform workspace new example1
```
Terraform wants to create a totally new EC2 Instance from scratch! That’s because the state files in each workspace are isolated from one another, and because you’re now in the example1 workspace, Terraform isn’t using the state file from the default workspace and therefore doesn’t see the EC2 Instance was already created there.


```bash
$ terraform workspace list
  default
  example1
* example2

$ terraform workspace select example1
Switched to workspace "example1".
```

Terraform workspaces can be a great way to quickly spin up and tear down different versions of your code, but they have a few drawbacks:

- The state files for all of your workspaces are stored in the same backend (e.g., the same S3 bucket). That means you use the same authentication and access controls for all the workspaces, which is one major reason workspaces are an unsuitable mechanism for isolating environments (e.g., isolating staging from production).

- Workspaces are not visible in the code or on the terminal unless you run terraform workspace commands. When browsing the code, a module that has been deployed in one workspace looks exactly the same as a module deployed in 10 workspaces. This makes maintenance more difficult, because you don’t have a good picture of your infrastructure.

- Putting the two previous items together, the result is that workspaces can be fairly error prone. The lack of visibility makes it easy to forget what workspace you’re in and accidentally deploy changes in the wrong one (e.g., accidentally running terraform destroy in a “production” workspace rather than a “staging” workspace), and because you must use the same authentication mechanism for all workspaces, you have no other layers of defense to protect against such errors.

- Due to these drawbacks, workspaces are not a suitable mechanism for isolating one environment from another: e.g., isolating staging from production.5 To get proper isolation between environments, instead of workspaces, you’ll most likely want to use file layout, which is the topic of the next section

### Isolation via File Layout
To achieve full isolation between environments, you need to do the following:

- Put the Terraform configuration files for each environment into a separate folder. For example, all of the configurations for the staging environment can be in a folder called stage and all the configurations for the production environment can be in a folder called prod.

- Configure a different backend for each environment, using different authentication mechanisms and access controls: e.g., each environment could live in a separate AWS account with a separate S3 bucket as a backend.



![recommended-approach](https://i.imgur.com/Z3iC9oX.png)


At the top level, there are separate folders for each “environment.” The exact environments differ for every project, but the typical ones are as follows:

**stage**
An environment for pre-production workloads (i.e., testing)

**prod**
An environment for production workloads (i.e., user-facing apps)

**mgmt**
An environment for DevOps tooling (e.g., bastion host, CI server)

**global**
A place to put resources that are used across all environments (e.g., S3, IAM)


Within each environment, there are separate folders for each “component.” The components differ for every project, but here are the typical ones:

**vpc**
The network topology for this environment.

**services**
The apps or microservices to run in this environment, such as a Ruby on Rails frontend or a Scala backend. Each app could even live in its own folder to isolate it from all the other apps.

**data-storage**
The data stores to run in this environment, such as MySQL or Redis. Each data store could even reside in its own folder to isolate it from all other data stores.

Within each component, there are the actual Terraform configuration files, which are organized according to the following naming conventions:

**variables.tf**
Input variables

**outputs.tf**
Output variables

**main.tf**
Resources and data sources

When you run Terraform, it simply looks for files in the current directory with the .tf extension, so you can use whatever filenames you want. However, although Terraform may not care about filenames, your teammates probably do. Using a consistent, predictable naming convention makes your code easier to browse: e.g., you’ll always know where to look to find a variable, output, or resource.

Note that the preceding convention is the minimum convention you should follow, because in virtually all uses of Terraform, it’s useful to be able to jump to the input variables, output variables, and resources very quickly, but you may want to go beyond this convention. Here are just a few examples:

**dependencies.tf**
It’s common to put all your data sources in a dependencies.tf file to make it easier to see what external things the code depends on.

**providers.tf**
You may want to put your provider blocks into a providers.tf file so you can see, at a glance, what providers the code talks to and what authentication you’ll have to provide.

**main-xxx.tf**
If the main.tf file is getting really long because it contains a large number of resources, you could break it down into smaller files that group the resources in some logical way: e.g., main-iam.tf could contain all the IAM resources, main-s3.tf could contain all the S3 resources, and so on. Using the main- prefix makes it easier to scan the list of files in a folder when they are organized alphabetically, as all the resources will be grouped together. It’s also worth noting that if you find yourself managing a very large number of resources and struggling to break them down across many files, that might be a sign that you should break your code into smaller modules instead, which is a topic I’ll dive into in Chapter 4.

### Types and Values
[Official Documentation](https://www.terraform.io/language/expressions/types)

The Terraform language uses the following types for its values:

- string: a sequence of Unicode characters representing some text, like "hello".
- number: a numeric value. The number type can represent both whole numbers like 15 and fractional values like 6.283185.
- bool: a boolean value, either true or false. bool values can be used in conditional logic.
- list (or tuple): a sequence of values, like ["us-west-1a", "us-west-1c"]. Elements in a list or tuple are identified by consecutive whole numbers, starting with zero.
- map (or object): a group of values identified by named labels, like {name = "Mabel", age = 52}.


#### Custom Validation Rules

You can specify custom validation rules for a particular variable by adding a validation block within the corresponding variable block. The example below checks whether the AMI ID has the correct syntax

```yaml
variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."

  validation {
    condition     = length(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-"
    error_message = "The image_id value must be a valid AMI id, starting with \"ami-\"."
  }
}

```

### Suppressing Values in CLI Output

Setting a variable as sensitive prevents Terraform from showing its value in the plan or apply output, when you use that variable elsewhere in your configuration.

Terraform will still record sensitive values in the state, and so anyone who can access the state data will have access to the sensitive values in cleartext. For more information, see Sensitive Data in State.

Declare a variable as sensitive by setting the sensitive argument to true:


```yaml
variable "user_information" {
  type = object({
    name    = string
    address = string
  })
  sensitive = true
}

resource "some_resource" "a" {
  name    = var.user_information.name
  address = var.user_information.address
}

```


### Local Values

https://www.terraform.io/language/values/locals

A local value assigns a name to an expression, so you can use the name multiple times within a module instead of repeating the expression.

```yaml
locals {
  service_name = "forum"
  owner        = "Community Team"
}
```

The expressions in local values are not limited to literal constants; they can also reference other values in the module in order to transform or combine them, including variables, resource attributes, or other local values:

```yaml
locals {
  # Ids for multiple sets of EC2 instances, merged together
  instance_ids = concat(aws_instance.blue.*.id, aws_instance.green.*.id)
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Service = local.service_name
    Owner   = local.owner
  }
}
```

Once a local value is declared, you can reference it in expressions as local.<NAME>.

```yaml
resource "aws_instance" "example" {
  # ...

  tags = local.common_tags
}
```
A local value can only be accessed in expressions within the module where it was declared.


### Terraform functions

[Official Documentation](https://www.terraform.io/language/functions)

The Terraform language includes a number of built-in functions that you can call from within expressions to transform and combine values. The general syntax for function calls is a function name followed by comma-separated arguments in parentheses:

### Debugging Terraform
[Official Documentation](https://www.terraform.io/internals/debugging)

Terraform has detailed logs that you can enable by setting the TF_LOG environment variable to any value. Enabling this setting causes detailed logs to appear on stderr.

You can set TF_LOG to one of the log levels (in order of decreasing verbosity) TRACE, DEBUG, INFO, WARN or ERROR to change the verbosity of the logs.

Setting TF_LOG to JSON outputs logs at the TRACE level or higher, and uses a parseable JSON encoding as the formatting.

### Dynamic blocks

https://developer.hashicorp.com/terraform/language/expressions/dynamic-blocks
Within top-level block constructs like resources, expressions can usually be used only when assigning a value to an argument using the name = expression form. This covers many uses, but some resource types include repeatable nested blocks in their arguments, which typically represent separate objects that are related to (or embedded within) the containing object:

### Taint resource 

- [Official Documentation](https://developer.hashicorp.com/terraform/cli/commands/taint)

The terraform taint command informs Terraform that a particular object has become degraded or damaged. Terraform represents this by marking the object as "tainted" in the Terraform state, and Terraform will propose to replace it in the next plan you create.

```yaml
terraform apply -replace="module.aws-docker.aws_instance.docker"
```

**`Recommended Alternative`**
For Terraform v0.15.2 and later, we recommend using the -replace option with terraform apply to force Terraform to replace an object even though there are no configuration changes that would require it.

```yaml
terraform apply -replace="aws_instance.example[0]"
```

We recommend the -replace option because the change will be reflected in the Terraform plan, letting you understand how it will affect your infrastructure before you take any externally-visible action. When you use terraform taint, other users could create a new plan against your tainted object before you can review the effects.