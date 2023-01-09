## Terraform overview 

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

[![terraform-video](https://www.terraform.io/_next/static/images/how-tf-works-2-88c36cecdbf1d3a92cc3976dd85ff8ad.png?fit=max&fm=png&q=80)](https://www.terraform.io/videos/oss-cli-demo.mp4)


## Key feature 

### Infra as code
Your infrastructure is described using a high level configuration syntax. This allowr your infrastructure to be versioned and treated as you would any other code. It can also be shared and re-used. 

### Execution Plans
Terraform generated an execution plan wth its "planning" step. This shows what terraform will do when you apply the configuration. This allows you to avoid any surprises when Terraform manipulates infrastrutucre. 

### Resource Graph 
Terraform builds infrastructure as efficiently as possible, and operators get insight into dependencies in their infrastructure. It accomplishes this by building a graph of all your resources, and it gives you greater insight into the creation and modification of any non-dependent resouces. 

### Change automation
Complex changes can be applied to your infrastructure with minimal interaction. With the combination of the execution plan and resource graph, you will know exactly what Terraform will change and in what order. This will help avoid many possible human errors.
