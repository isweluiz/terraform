## Categories of IaC tools

* Ad hoc scripts
* Configuration management tools
* Server templating tools
* Orchestration tools
* Provisioning tools

#### Ad hoc scripts

The most straightforward approach to automating anything is to write an ad hoc script. You take whatever task you were doing manually, break it down into discrete steps, use your favorite scripting language (e.g., Bash, Ruby, Python) to define each of those steps in code, and execute that script on your server.

For example, here is a Bash script called setup-webserver.sh that configures a web server by installing dependencies, checking out some code from a Git repo, and firing up an Apache web server:

```bash
# Update the apt-get cache
sudo apt-get update

# Install PHP and Apache
sudo apt-get install -y php apache2

# Copy the code from the repository
sudo git clone https://github.com/brikis98/php-app.git /var/www/html/app

# Start Apache
sudo service apache2 start

```
If you’ve ever had to maintain a large repository of Bash scripts, you know that it almost always devolves into a mess of unmaintainable spaghetti code. Ad hoc scripts are great for small, one-off tasks, but if you’re going to be managing all of your infrastructure as code, then you should use an IaC tool that is purpose-built for the job.

### Configuration Management Tools

Chef, Puppet, and Ansible are all configuration management tools, which means that they are designed to install and manage software on existing servers. For example, here is an Ansible role called web-server.yml that configures the same Apache web server as the setup-webserver.sh script:

```yaml
- name: Update the apt-get cache
  apt:
    update_cache: yes

- name: Install PHP
  apt:
    name: php

- name: Install Apache
  apt:
    name: apache2

- name: Copy the code from the repository
  git: repo=https://github.com/brikis98/php-app.git dest=/var/www/html/app

- name: Start Apache
  service: name=apache2 state=started enabled=yes
```

The code looks similar to the Bash script, but using a tool like Ansible offers a number of advantages:

**Coding conventions**
Ansible enforces a consistent, predictable structure, including documentation, file layout, clearly named parameters, secrets management, and so on. While every developer organizes their ad hoc scripts in a different way, most configuration management tools come with a set of conventions that makes it easier to navigate the code.

**Idempotence**
Writing an ad hoc script that works once isn’t too difficult; writing an ad hoc script that works correctly even if you run it over and over again is much harder. Every time you go to create a folder in your script, you need to remember to check whether that folder already exists; every time you add a line of configuration to a file, you need to check that line doesn’t already exist; every time you want to run an app, you need to check that the app isn’t already running.

Code that works correctly no matter how many times you run it is called idempotent code. To make the Bash script from the previous section idempotent, you’d need to add many lines of code, including lots of if-statements. Most Ansible functions, on the other hand, are idempotent by default. For example, the web-server.yml Ansible role will install Apache only if it isn’t installed already and will try to start the Apache web server only if it isn’t running already.

**Distribution**
Ad hoc scripts are designed to run on a single, local machine. Ansible and other configuration management tools are designed specifically for managing large numbers of remote servers,


### Server Templating Tools

An alternative to configuration management that has been growing in popularity recently are server templating tools such as Docker, Packer, and Vagrant. Instead of launching a bunch of servers and configuring them by running the same code on each one, the idea behind server templating tools is to create an image of a server that captures a fully self-contained “snapshot” of the operating system (OS), the software, the files, and all other relevant details. You can then use some other IaC tool to install that image on all of your servers,



**Virtual machines**
A virtual machine (VM) emulates an entire computer system, including the hardware. You run a hypervisor, such as VMware, VirtualBox, or Parallels, to virtualize (i.e., simulate) the underlying CPU, memory, hard drive, and networking.

The benefit of this is that any VM image that you run on top of the hypervisor can see only the virtualized hardware, so it’s fully isolated from the host machine and any other VM images, and it will run exactly the same way in all environments (e.g., your computer, a QA server, a production server). The drawback is that virtualizing all this hardware and running a totally separate OS for each VM incurs a lot of overhead in terms of CPU usage, memory usage, and startup time. You can define VM images as code using tools such as Packer and Vagrant.

**Containers**
A container emulates the user space of an OS.2 You run a container engine, such as Docker, CoreOS rkt, or cri-o, to create isolated processes, memory, mount points, and networking.

The benefit of this is that any container you run on top of the container engine can see only its own user space, so it’s isolated from the host machine and other containers and will run exactly the same way in all environments (your computer, a QA server, a production server, etc.). The drawback is that all of the containers running on a single server share that server’s OS kernel and hardware, so it’s much more difficult to achieve the level of isolation and security you get with a VM.3 However, because the kernel and hardware are shared, your containers can boot up in milliseconds and have virtually no CPU or memory overhead. You can define container images as code using tools such as Docker and CoreOS rkt


For example, here is a Packer template called web-server.json that creates an Amazon Machine Image (AMI), which is a VM image that you can run on AWS:


```json
{
  "builders": [{
    "ami_name": "packer-example-",
    "instance_type": "t2.micro",
    "region": "us-east-2",
    "type": "amazon-ebs",
    "source_ami": "ami-0fb653ca2d3203ac1",
    "ssh_username": "ubuntu"
  }],
  "provisioners": [{
    "type": "shell",
    "inline": [
      "sudo apt-get update",
      "sudo apt-get install -y php apache2",
      "sudo git clone https://github.com/brikis98/php-app.git /var/www/html/app"
    ],
    "environment_vars": [
      "DEBIAN_FRONTEND=noninteractive"
    ],
    "pause_before": "60s"
  }]
}
```

This Packer template configures the same Apache web server that you saw in setup-webserver.sh using the same Bash code. The only difference between the code in the Packer template and the previous examples is that this Packer template does not start the Apache web server (e.g., by calling sudo service apache2 start). That’s because server templates are typically used to install software in images, but it’s only when you run the image—for example, by deploying it on a server—that you should actually run that software.

To build an AMI from this template, run packer build webserver.json. After the build completes, you can install that AMI on all of your AWS servers and configure each server to run Apache when the server is booting (you’ll see an example of this in the next section), and they will all run exactly the same way.

Note that the different server templating tools have slightly different purposes. Packer is typically used to create images that you run directly on top of production servers, such as an AMI that you run in your production AWS account. Vagrant is typically used to create images that you run on your development computers, such as a VirtualBox image that you run on your Mac or Windows laptop. Docker is typically used to create images of individual applications. You can run the Docker images on production or development computers, as long as some other tool has configured that computer with the Docker Engine. For example, a common pattern is to use Packer to create an AMI that has the Docker Engine installed, deploy that AMI on a cluster of servers in your AWS account, and then deploy individual Docker containers across that cluster to run your applications.

Server templating is a key component of the shift to immutable infrastructure. This idea is inspired by functional programming, where variables are immutable, so after you’ve set a variable to a value, you can never change that variable again. If you need to update something, you create a new variable. Because variables never change, it’s a lot easier to reason about your code.

The idea behind immutable infrastructure is similar: once you’ve deployed a server, you never make changes to it again. If you need to update something, such as deploying a new version of your code, you create a new image from your server template and you deploy it on a new server. Because servers never change, it’s a lot easier to reason about what’s deployed.


### Orchestration Tools

Server templating tools are great for creating VMs and containers, but how do you actually manage them? For most real-world use cases, you’ll need a way to do the following:

Deploy VMs and containers, making efficient use of your hardware.

Roll out updates to an existing fleet of VMs and containers using strategies such as rolling deployment, blue-green deployment, and canary deployment.

Monitor the health of your VMs and containers and automatically replace unhealthy ones (auto healing).

Scale the number of VMs and containers up or down in response to load (auto scaling).

Distribute traffic across your VMs and containers (load balancing).

Allow your VMs and containers to find and talk to one another over the network (service discovery).

Handling these tasks is the realm of orchestration tools such as Kubernetes, Marathon/Mesos, Amazon Elastic Container Service (Amazon ECS), Docker Swarm, and Nomad. For example, Kubernetes allows you to define how to manage your Docker containers as code. You first deploy a Kubernetes cluster, which is a group of servers that Kubernetes will manage and use to run your Docker containers. Most major cloud providers have native support for deploying managed Kubernetes clusters, such as Amazon Elastic Kubernetes Service (EKS), Google Kubernetes Engine (GKE), and Azure Kubernetes Service (AKS).

Once you have a working cluster, you can define how to run your Docker container as code in a YAML file:

```yaml
apiVersion: apps/v1

# Use a Deployment to deploy multiple replicas of your Docker
# container(s) and to declaratively roll out updates to them
kind: Deployment

# Metadata about this Deployment, including its name
metadata:
  name: example-app

# The specification that configures this Deployment
spec:
  # This tells the Deployment how to find your container(s)
  selector:
    matchLabels:
      app: example-app

  # This tells the Deployment to run three replicas of your
  # Docker container(s)
  replicas: 3

  # Specifies how to update the Deployment. Here, we
  # configure a rolling update.
  strategy:
    rollingUpdate:
      maxSurge: 3
      maxUnavailable: 0
    type: RollingUpdate

  # This is the template for what container(s) to deploy
  template:

    # The metadata for these container(s), including labels
    metadata:
      labels:
        app: example-app

    # The specification for your container(s)
    spec:
      containers:

        # Run Apache listening on port 80
        - name: example-app
          image: httpd:2.4.39
          ports:
            - containerPort: 80

```
This file instructs Kubernetes to create a Deployment, which is a declarative way to define the following:

One or more Docker containers to run together. This group of containers is called a Pod. The Pod defined in the preceding code contains a single Docker container that runs Apache.

The settings for each Docker container in the Pod. The Pod in the preceding code configures Apache to listen on port 80.

How many copies (aka replicas) of the Pod to run in your cluster. The preceding code configures three replicas. Kubernetes automatically figures out where in your cluster to deploy each Pod, using a scheduling algorithm to pick the optimal servers in terms of high availability (e.g., try to run each Pod on a separate server so a single server crash doesn’t take down your app), resources (e.g., pick servers that have available the ports, CPU, memory, and other resources required by your containers), performance (e.g., try to pick servers with the least load and fewest containers on them), and so on. Kubernetes also constantly monitors the cluster to ensure that there are always three replicas running, automatically replacing any Pods that crash or stop responding.

How to deploy updates. When deploying a new version of the Docker container, the preceding code rolls out three new replicas, waits for them to be healthy, and then undeploys the three old replicas.

That’s a lot of power in just a few lines of YAML! You run kubectl apply -f example-app.yml to instruct Kubernetes to deploy your app. You can then make changes to the YAML file and run kubectl apply again to roll out the updates. You can also manage both the Kubernetes cluster and the apps within it using Terraform.

### Provisioning Tools

Whereas configuration management, server templating, and orchestration tools define the code that runs on each server, provisioning tools such as Terraform, CloudFormation, OpenStack Heat, and Pulumi are responsible for creating the servers themselves. In fact, you can use provisioning tools to create not only servers but also databases, caches, load balancers, queues, monitoring, subnet configurations, firewall settings, routing rules, Secure Sockets Layer (SSL) certificates, and almost every other aspect of your infrastructure.

For example, the following code deploys a web server using Terraform:

```json
resource "aws_instance" "app" {
  instance_type     = "t2.micro"
  availability_zone = "us-east-2a"
  ami               = "ami-0fb653ca2d3203ac1"

  user_data = <<-EOF
              #!/bin/bash
              sudo service apache2 start
              EOF
}
```
Don’t worry if you’re not yet familiar with some of the syntax. For now, just focus on two parameters:

ami
This parameter specifies the ID of an AMI to deploy on the server. You could set this parameter to the ID of an AMI built from the web-server.json Packer template in the previous section, which has PHP, Apache, and the application source code.

user_data
This is a Bash script that executes when the web server is booting. The preceding code uses this script to boot up Apache.

In other words, this code shows you provisioning and server templating working together, which is a common pattern in immutable infrastructure.

### Mutable Infrastructure Versus Immutable Infrastructure

Configuration management tools such as Chef, Puppet, and Ansible typically default to a mutable infrastructure paradigm.

For example, if you instruct Chef to install a new version of OpenSSL, it will run the software update on your existing servers, and the changes will happen in place. Over time, as you apply more and more updates, each server builds up a unique history of changes. As a result, each server becomes slightly different than all the others, leading to subtle configuration bugs that are difficult to diagnose and reproduce (this is the same configuration drift problem that happens when you manage servers manually, although it’s much less problematic when using a configuration management tool). Even with automated tests, these bugs are difficult to catch; a configuration management change might work just fine on a test server, but that same change might behave differently on a production server because the production server has accumulated months of changes that aren’t reflected in the test environment.

If you’re using a provisioning tool such as Terraform to deploy machine images created by Docker or Packer, most “changes” are actually deployments of a completely new server. For example, to deploy a new version of OpenSSL, you would use Packer to create a new image with the new version of OpenSSL, deploy that image across a set of new servers, and then terminate the old servers. Because every deployment uses immutable images on fresh servers, this approach reduces the likelihood of configuration drift bugs, makes it easier to know exactly what software is running on each server, and allows you to easily deploy any previous version of the software (any previous image) at any time. It also makes your automated testing more effective, because an immutable image that passes your tests in the test environment is likely to behave exactly the same way in the production environment.

Of course, it’s possible to force configuration management tools to do immutable deployments, too, but it’s not the idiomatic approach for those tools, whereas it’s a natural way to use provisioning tools. It’s also worth mentioning that the immutable approach has downsides of its own. For example, rebuilding an image from a server template and redeploying all your servers for a trivial change can take a long time. Moreover, immutability lasts only until you actually run the image. After a server is up and running, it will begin making changes on the hard drive and experiencing some degree of configuration drift (although this is mitigated if you deploy frequently).

### Procedural Language Versus Declarative Language

Chef and Ansible encourage a procedural style in which you write code that specifies, step by step, how to achieve some desired end state.

Terraform, CloudFormation, Puppet, OpenStack Heat, and Pulumi all encourage a more declarative style in which you write code that specifies your desired end state, and the IaC tool itself is responsible for figuring out how to achieve that state.

To demonstrate the difference, let’s go through an example. Imagine that you want to deploy 10 servers (EC2 Instances in AWS lingo) to run an AMI with ID ami-0fb653ca2d3203ac1 (Ubuntu 20.04). Here is a simplified example of an Ansible template that does this using a procedural approach:

```yaml
- ec2:
    count: 10
    image: ami-0fb653ca2d3203ac1
    instance_type: t2.micro
```

And here is a simplified example of a Terraform configuration that does the same thing using a declarative approach:

```yaml
resource "aws_instance" "example" {
  count         = 10
  ami           = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
}
```

On the surface, these two approaches might look similar, and when you initially execute them with Ansible or Terraform, they will produce similar results. The interesting thing is what happens when you want to make a change.

For example, imagine traffic has gone up, and you want to increase the number of servers to 15. With Ansible, the procedural code you wrote earlier is no longer useful; if you just updated the number of servers to 15 and reran that code, it would deploy 15 new servers, giving you 25 total! So instead, you need to be aware of what is already deployed and write a totally new procedural script to add the five new servers:

```yaml
- ec2:
    count: 5
    image: ami-0fb653ca2d3203ac1
    instance_type: t2.micro

```

With declarative code, because all you do is declare the end state that you want and Terraform figures out how to get to that end state, Terraform will also be aware of any state it created in the past. Therefore, to deploy five more servers, all you need to do is go back to the same Terraform configuration and update the count from 10 to 15:

```json
resource "aws_instance" "example" {
  count         = 15
  ami           = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
}
```

If you applied this configuration, Terraform would realize it had already created 10 servers and therefore all it needs to do is create five new servers. In fact, before applying this configuration, you can use Terraform’s plan command to preview what changes it would make:

```bash
$ terraform plan

# aws_instance.example[11] will be created
+ resource "aws_instance" "example" {
    + ami            = "ami-0fb653ca2d3203ac1"
    + instance_type  = "t2.micro"
    + (...)
  }

# aws_instance.example[12] will be created
+ resource "aws_instance" "example" {
    + ami            = "ami-0fb653ca2d3203ac1"
    + instance_type  = "t2.micro"
    + (...)
  }

# aws_instance.example[13] will be created
+ resource "aws_instance" "example" {
    + ami            = "ami-0fb653ca2d3203ac1"
    + instance_type  = "t2.micro"
    + (...)
  }

# aws_instance.example[14] will be created
+ resource "aws_instance" "example" {
    + ami            = "ami-0fb653ca2d3203ac1"
    + instance_type  = "t2.micro"
    + (...)
  }

Plan: 5 to add, 0 to change, 0 to destroy.
```

Now what happens when you want to deploy a different version of the app, such as AMI ID ami-02bcbb802e03574ba? With the procedural approach, both of your previous Ansible templates are again not useful, so you need to write yet another template to track down the 10 servers you deployed previously (or was it 15 now?) and carefully update each one to the new version. With the declarative approach of Terraform, you go back to the exact same configuration file again and simply change the ami parameter to ami-02bcbb802e03574ba:

```json
resource "aws_instance" "example" {
  count         = 15
  ami           = "ami-02bcbb802e03574ba"
  instance_type = "t2.micro"
}
```

Obviously, these examples are simplified. Ansible does allow you to use tags to search for existing EC2 Instances before deploying new ones (e.g., using the instance_tags and count_tag parameters), but having to manually figure out this sort of logic for every single resource you manage with Ansible, based on each resource’s past history, can be surprisingly complicated: for example, you may have to manually configure your code to look up existing Instances not only by tag but also by image version, Availability Zone, and other parameters. This highlights two major problems with procedural IaC tools:

**Procedural code does not fully capture the state of the infrastructure**
Reading through the three preceding Ansible templates is not enough to know what’s deployed. You’d also need to know the order in which those templates were applied. Had you applied them in a different order, you might have ended up with different infrastructure, and that’s not something you can see in the codebase itself. In other words, to reason about an Ansible or Chef codebase, you need to know the full history of every change that has ever happened.

**Procedural code limits reusability**
The reusability of procedural code is inherently limited because you must manually take into account the current state of the infrastructure. Because that state is constantly changing, code you used a week ago might no longer be usable because it was designed to modify a state of your infrastructure that no longer exists. As a result, procedural codebases tend to grow large and complicated over time.

With Terraform’s declarative approach, the code always represents the latest state of your infrastructure. At a glance, you can determine what’s currently deployed and how it’s configured, without having to worry about history or timing. This also makes it easy to create reusable code, since you don’t need to manually account for the current state of the world. Instead, you just focus on describing your desired state, and Terraform figures out how to get from one state to the other automatically. As a result, Terraform codebases tend to stay small and easy to understand.

### General-Purpose Language Versus Domain-Specific Language
Chef and Pulumi allow you to use a general-purpose programming language (GPL) to manage infrastructure as code: Chef supports Ruby; Pulumi supports a wide variety of GPLs, including JavaScript, TypeScript, Python, Go, C#, Java, and others. Terraform, Puppet, Ansible, CloudFormation, and OpenStack Heat each use a domain-specific language (DSL) to manage infrastructure as code: Terraform uses HCL; Puppet uses Puppet Language; Ansible, CloudFormation, and OpenStack Heat use YAML (CloudFormation also supports JSON).

