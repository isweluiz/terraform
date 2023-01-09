## Getting started with terraform and AWS

* Setting up your AWS account

* Installing Terraform

* Deploying a single server

* Deploying a single web server

* Deploying a configurable web server

* Deploying a cluster of web servers

* Deploying a load balancer

* Cleaning up


### Setting Up Your AWS Account
If you don’t already have an AWS account, head over to https://aws.amazon.com and sign up. When you first register for AWS, you initially sign in as the root user. This user account has access permissions to do absolutely anything in the account, so from a security perspective, it’s not a good idea to use the root user on a day-to-day basis. In fact, the only thing you should use the root user for is to create other user accounts with more-limited permissions, and then switch to one of those accounts immediately.4

To create a more-limited user account, you will need to use the Identity and Access Management (IAM) service. IAM is where you manage user accounts as well as the permissions for each user. To create a new IAM user, go to the IAM Console, click Users, and then click the Add Users button. Enter a name for the user, and make sure “Access key - Programmatic access” is selected, as shown in 

![aws](https://i.imgur.com/ud12tlm.png)

Click the Next button. AWS will ask you to add permissions to the user. By default, new IAM users have no permissions whatsoever and cannot do anything in an AWS account. To give your IAM user the ability to do something, you need to associate one or more IAM Policies with that user’s account. An IAM Policy is a JSON document that defines what a user is or isn’t allowed to do. You can create your own IAM Policies or use some of the predefined IAM Policies built into your AWS account, which are known as Managed Policies.5

![permission](https://i.imgur.com/mwqEpKT.png)

To run the examples in this book, the easiest way to get started is to add the AdministratorAccess Managed Policy to your IAM user (search for it, and click the checkbox next to it), as shown in Figure 2-2.6

For Terraform to be able to make changes in your AWS account, you will need to set the AWS credentials for the IAM user you created earlier as the environment variables AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY. For example, here is how you can do it in a Unix/Linux/macOS terminal:

```bash
$ export AWS_ACCESS_KEY_ID=<id>
$ export AWS_SECRET_ACCESS_KEY=<key>
```

### Deploying a Single Server

Terraform code is written in the HashiCorp Configuration Language (HCL) in files with the extension .tf.7 It is a declarative language, so your goal is to describe the infrastructure you want, and Terraform will figure out how to create it. Terraform can create infrastructure across a wide variety of platforms, or what it calls providers, including AWS, Azure, Google Cloud, DigitalOcean, and many others.

The first step to using Terraform is typically to configure the provider(s) you want to use. Create an empty folder and put a file in it called main.tf that contains the following contents:

```json
provider "aws" {
  region = "us-east-2"
}
```

This tells Terraform that you are going to be using AWS as your provider and that you want to deploy your infrastructure into the us-east-2 region. AWS has datacenters all over the world, grouped into regions. An AWS region is a separate geographic area, such as us-east-2 (Ohio), eu-west-1 (Ireland), and ap-southeast-2 (Sydney). Within each region, there are multiple isolated datacenters known as Availability Zones (AZs), such as us-east-2a, us-east-2b, and so on.8 There are many other settings you can configure on this provider, but for now, let’s keep it simple.

For each type of provider, there are many different kinds of resources that you can create, such as servers, databases, and load balancers. The general syntax for creating a resource in Terraform is as follows:

```json
resource "<PROVIDER>_<TYPE>" "<NAME>" {
  [CONFIG ...]
}
```

where `PROVIDER` is the name of a provider (e.g., aws), `TYPE` is the type of resource to create in that provider (e.g., instance), `NAME` is an identifier you can use throughout the Terraform code to refer to this resource (e.g., my_instance), and `CONFIG` consists of one or more arguments that are specific to that resource.

For example, to deploy a single (virtual) server in AWS, known as an EC2 Instance, use the `aws_instance` resource in main.tf as follows:

```json
resource "aws_instance" "example" {
  ami           = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
}
```

The `aws_instance` resource supports many different arguments, but for now, you only need to set the two required ones:

**ami**
The Amazon Machine Image (AMI) to run on the EC2 Instance. You can find free and paid AMIs in the AWS Marketplace or create your own using tools such as Packer. The preceding code sets the ami parameter to the ID of an Ubuntu 20.04 AMI in us-east-2. This AMI is free to use. Please note that AMI IDs are different in every AWS region, so if you change the region parameter to something other than us-east-2, you’ll need to manually look up the corresponding Ubuntu AMI ID for that region,9 and copy it into the ami parameter. In Chapter 7, you’ll see how to fetch the AMI ID completely automatically.

**instance_type**
The type of EC2 Instance to run. Each type of EC2 Instance provides a different amount of CPU, memory, disk space, and networking capacity. The EC2 Instance Types page lists all the available options. The preceding example uses t2.micro, which has one virtual CPU, 1 GB of memory, and is part of the AWS Free Tier.


### Git ignore 

You should also create a .gitignore file with the following contents:

```
.terraform
*.tfstate
*.tfstate.backup
```

The preceding .gitignore file instructs Git to ignore the .terraform folder, which Terraform uses as a temporary scratch directory, as well as *.tfstate files, which Terraform uses to store state 