### What is Terraform? 

Terraform is an open source tool created by HashiCorp that allows you to define your infrastructure as code using a simple, declarative language and to deploy and manage that infrastructure across a variety of public cloud providers (e.g., Amazon Web Services [AWS], Microsoft Azure, Google Cloud Platform, DigitalOcean) and private cloud and virtualization platforms (e.g., OpenStack, VMware) using a few commands. For example, instead of manually clicking around a web page or running dozens of commands, here is all the code it takes to configure a server on AWS:

```ini
provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "example" {
  ami           = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
}
```

And to deploy it, you just run the following:

```bash
$ terraform init
$ terraform apply
```

Terraform creates and manages resources on cloud platforms and other services through their application programming interfaces (APIs). Providers enable Terraform to work with virtually any platform or service with an accessible API.

![](https://content.hashicorp.com/api/assets?product=terraform&version=refs%2Fheads%2Fv1.3&asset=website%2Fimg%2Fdocs%2Fintro-terraform-apis.png&width=2048&height=644)

...[more](https://www.terraform.io/intro)

#### Terraform Tools
Terraform is part of a rich infrastructure and DevOps ecosystem. The tools below extend Terraform’s functionality or pair with Terraform to solve a broad range of infrastructure challenges.
...[more](https://www.terraform.io/docs/terraform-tools)

#### Terraform Workflow 

The core Terraform workflow consists of three stages:

![stages](https://i.imgur.com/DcQdxHo.png)

**Write**: You define resources, which may be across multiple cloud providers and services. For example, you might create a configuration to deploy an application on virtual machines in a Virtual Private Cloud (VPC) network with security groups and a load balancer.

**Plan**: Terraform creates an execution plan describing the infrastructure it will create, update, or destroy based on the existing infrastructure and your configuration.

**Apply**: On approval, Terraform performs the proposed operations in the correct order, respecting any resource dependencies. For example, if you update the properties of a VPC and change the number of virtual machines in that VPC, Terraform will recreate the VPC before scaling the virtual machines.

#### Application Infrastructure Deployment, Scaling, and Monitoring Tools

You can use Terraform to efficiently deploy, release, scale, and monitor infrastructure for multi-tier applications. N-tier application architecture lets you scale application components independently and provides a separation of concerns. An application could consist of a pool of web servers that use a database tier, with additional tiers for API servers, caching servers, and routing meshes. Terraform allows you to manage the resources in each tier together, and automatically handles dependencies between tiers. For example, Terraform will deploy a database tier before provisioning the web servers that depend on it.

#### Kubernetes
Kubernetes is an open-source workload scheduler for containerized applications. Terraform lets you both deploy a Kubernetes cluster and manage its resources (e.g., pods, deployments, services, etc.). You can also use the [Kubernetes Operator](https://github.com/hashicorp/terraform-k8s) for Terraform to manage cloud and on-prem infrastructure through a Kubernetes Custom Resource Definition (CRD) and Terraform Cloud.

#### Parallel Environments
You may have staging or QA environments that you use to test new applications before releasing them in production. As the production environment grows larger and more complex, it can be increasingly difficult to maintain an up-to-date environment for each stage of the development process. Terraform lets you rapidly spin up and decommission infrastructure for development, test, QA, and production. Using Terraform to create disposable environments as needed is more cost-efficient than maintaining each one indefinitely.


...[more](https://www.terraform.io/intro/use-cases)

### Terraform overview 

My notes about terraform official documentation, during the studys.

- [Terraform intro - What is? How does it works?](https://www.terraform.io/intro)
- [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [Terraform CLI](https://www.terraform.io/cli)
- [Terraform cheat sheet](https://acloudguru.com/blog/engineering/the-ultimate-terraform-cheatsheet)
- [Terraform Language](https://www.terraform.io/language)
- [Override Files](https://www.terraform.io/language/files/override)
- [Resources](https://www.terraform.io/language/resources)
- [Input Variables](https://www.terraform.io/language/values/variables)
- [Output values](https://www.terraform.io/language/values/outputs)
- [Local variables](https://www.terraform.io/language/values/locals)
- [How to use inputs and outputs - Blog post](https://acloudguru.com/blog/engineering/how-to-use-terraform-inputs-and-outputs)
- [Modules](https://www.terraform.io/language/modules)


## Key feature 

### Infra as code
Your infrastructure is described using a high level configuration syntax. This allowr your infrastructure to be versioned and treated as you would any other code. It can also be shared and re-used. 

### Execution Plans
Terraform generated an execution plan wth its "planning" step. This shows what terraform will do when you apply the configuration. This allows you to avoid any surprises when Terraform manipulates infrastrutucre. 

### Resource Graph 
Terraform builds infrastructure as efficiently as possible, and operators get insight into dependencies in their infrastructure. It accomplishes this by building a graph of all your resources, and it gives you greater insight into the creation and modification of any non-dependent resouces. 

### Change automation
Complex changes can be applied to your infrastructure with minimal interaction. With the combination of the execution plan and resource graph, you will know exactly what Terraform will change and in what order. This will help avoid many possible human errors.

### What Are the Benefits of Infrastructure as Code?

Now that you’ve seen all the different flavors of IaC, a good question to ask is, why bother? Why learn a bunch of new languages and tools and encumber yourself with yet more code to manage?

The answer is that code is powerful. In exchange for the upfront investment of converting your manual practices to code, you get dramatic improvements in your ability to deliver software. According to the 2016 State of DevOps Report, organizations that use DevOps practices, such as IaC, deploy 200 times more frequently, recover from failures 24 times faster, and have lead times that are 2,555 times lower.

When your infrastructure is defined as code, you are able to use a wide variety of software engineering practices to dramatically improve your software delivery process, including the following:

**Self-service**
Most teams that deploy code manually have a small number of sysadmins (often, just one) who are the only ones who know all the magic incantations to make the deployment work and are the only ones with access to production. This becomes a major bottleneck as the company grows. If your infrastructure is defined in code, the entire deployment process can be automated, and developers can kick off their own deployments whenever necessary.

**Speed and safety**
If the deployment process is automated, it will be significantly faster, since a computer can carry out the deployment steps far faster than a person, and safer, given that an automated process will be more consistent, more repeatable, and not prone to manual error.

**Documentation**
If the state of your infrastructure is locked away in a single sysadmin’s head, and that sysadmin goes on vacation or leaves the company or gets hit by a bus,4 you may suddenly realize you can no longer manage your own infrastructure. On the other hand, if your infrastructure is defined as code, then the state of your infrastructure is in source files that anyone can read. In other words, IaC acts as documentation, allowing everyone in the organization to understand how things work, even if the sysadmin goes on vacation.

**Version control**
You can store your IaC source files in version control, which means that the entire history of your infrastructure is now captured in the commit log. This becomes a powerful tool for debugging issues, because any time a problem pops up, your first step will be to check the commit log and find out what changed in your infrastructure, and your second step might be to resolve the problem by simply reverting back to a previous, known-good version of your IaC code.

**Validation**
If the state of your infrastructure is defined in code, for every single change, you can perform a code review, run a suite of automated tests, and pass the code through static analysis tools—all practices that are known to significantly reduce the chance of defects.

**Reuse**
You can package your infrastructure into reusable modules so that instead of doing every deployment for every product in every environment from scratch, you can build on top of known, documented, battle-tested pieces.5

**Happiness**
There is one other very important, and often overlooked, reason for why you should use IaC: happiness. Deploying code and managing infrastructure manually is repetitive and tedious. Developers and sysadmins resent this type of work, since it involves no creativity, no challenge, and no recognition. You could deploy code perfectly for months, and no one will take notice—until that one day when you mess it up. That creates a stressful and unpleasant environment. IaC offers a better alternative that allows computers to do what they do best (automation) and developers to do what they do best (coding).

Now that you have a sense of why IaC is important, the next question is whether Terraform is the best IaC tool for you. To answer that, I’m first going to go through a very quick primer on how Terraform works, and then I’ll compare it to the other popular IaC options out there, such as Chef, Puppet, and Ansible.


### How Does Terraform Compare to Other IaC Tools?
Infrastructure as code is wonderful, but the process of picking an IaC tool is not. Many of the IaC tools overlap in what they do. Many of them are open source. Many of them offer commercial support. Unless you’ve used each one yourself, it’s not clear what criteria you should use to pick one or the other.

What makes this even more difficult is that most of the comparisons you find between these tools do little more than list the general properties of each one and make it sound as if you could be equally successful with any of them. And although that’s technically true, it’s not helpful. It’s a bit like telling a programming newbie that you could be equally successful building a website with PHP, C, or assembly—a statement that’s technically true but one that omits a huge amount of information that is essential for making a good decision.

In the following sections, I’m going to do a detailed comparison between the most popular configuration management and provisioning tools: Terraform, Chef, Puppet, Ansible, Pulumi, CloudFormation, and OpenStack Heat. My goal is to help you decide whether Terraform is a good choice by explaining why my company, Gruntwork, picked Terraform as our IaC tool of choice and, in some sense, why I wrote this book.6 As with all technology decisions, it’s a question of trade-offs and priorities, and even though your particular priorities might be different than mine, my hope is that sharing this thought process will help you to make your own decision.

* Here are the main trade-offs to consider:
* Configuration management versus provisioning
* Mutable infrastructure versus immutable infrastructure
* Procedural language versus declarative language
* General-purpose language versus domain-specific language
* Master versus masterless
* Agent versus agentless
* Paid versus free offering
* Large community versus small community
* Mature versus cutting-edge
* Use of multiple tools together


### Configuration Management Versus Provisioning
As you saw earlier, Chef, Puppet, and Ansible are all configuration management tools, whereas CloudFormation, Terraform, OpenStack Heat, and Pulumi are all provisioning tools.

Although the distinction is not entirely clear cut, given that configuration management tools can typically do some degree of provisioning (e.g., you can deploy a server with Ansible) and that provisioning tools can typically do some degree of configuration (e.g., you can run configuration scripts on each server you provision with Terraform), you typically want to pick the tool that’s the best fit for your use case.

In particular, if you use server templating tools, the vast majority of your configuration management needs are already taken care of. Once you have an image created from a Dockerfile or Packer template, all that’s left to do is provision the infrastructure for running those images. And when it comes to provisioning, a provisioning tool is going to be your best choice. In Chapter 7, you’ll see an example of how to use Terraform and Docker together, which is a particularly popular combination these days.

That said, if you’re not using server templating tools, a good alternative is to use a configuration management and provisioning tool together. For example, a popular combination is to use Terraform to provision your servers and Ansible to configure each one.