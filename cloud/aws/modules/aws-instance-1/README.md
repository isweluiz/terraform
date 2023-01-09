### Deploying a Single Web Server
The next step is to run a web server on this Instance. The goal is to deploy the simplest web architecture possible: a single web server that can respond to HTTP requests.

![](https://i.imgur.com/c8aGlOu.png)

In a real-world use case, you’d probably build the web server using a web framework like Ruby on Rails or Django, but to keep this example simple, let’s run a dirt-simple web server that always returns the text “Hello, World”:

```bash
#!/bin/bash
echo "Hello, World" > index.html
nohup busybox httpd -f -p 8080 &
```

This is a Bash script that writes the text “Hello, World” into index.html and runs a tool called busybox (which is installed by default on Ubuntu) to fire up a web server on port 8080 to serve that file. I wrapped the busybox command with nohup and an ampersand (&) so that the web server runs permanently in the background, whereas the Bash script itself can exit.

> The reason this example uses port 8080, rather than the default HTTP port 80, is that listening on any port less than 1024 requires root user privileges. This is a security risk since any attacker who manages to compromise your server would get root privileges, too.


#### Two things to notice about the preceding code:

- The <<-EOF and EOF are Terraform’s heredoc syntax, which allows you to create multiline strings without having to insert \n characters all over the place.

- The user_data_replace_on_change parameter is set to true so that when you change the user_data parameter and run apply, Terraform will terminate the original instance and launch a totally new one. Terraform’s default behavior is to update the original instance in place, but since User Data runs only on the very first boot, and your original instance already went through that boot process, you need to force the creation of a new instance to ensure your new User Data script actually gets executed.

#### Network 
You need to do one more thing before this web server works. By default, AWS does not allow any incoming or outgoing traffic from an EC2 Instance. To allow the EC2 Instance to receive traffic on port 8080, you need to create a security group:

```json
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

This code creates a new resource called aws_security_group (notice how all resources for the AWS Provider begin with aws_) and specifies that this group allows incoming TCP requests on port 8080 from the CIDR block 0.0.0.0/0. CIDR blocks are a concise way to specify IP address ranges. For example, a CIDR block of 10.0.0.0/24 represents all IP addresses between 10.0.0.0 and 10.0.0.255. The CIDR block 0.0.0.0/0 is an IP address range that includes all possible IP addresses, so this security group allows incoming requests on port 8080 from any IP

Simply creating a security group isn’t enough; you need to tell the EC2 Instance to actually use it by passing the ID of the security group into the vpc_security​_group_ids argument of the aws_instance resource. To do that, you first need to learn about Terraform expressions.

One particularly useful type of expression is a reference, which allows you to access values from other parts of your code. To access the ID of the security group resource, you are going to need to use a resource attribute reference, which uses the following syntax:

```
<PROVIDER>_<TYPE>.<NAME>.<ATTRIBUTE>
```

where PROVIDER is the name of the provider (e.g., aws), TYPE is the type of resource (e.g., security_group), NAME is the name of that resource (e.g., the security group is named "instance"), and ATTRIBUTE is either one of the arguments of that resource (e.g., name) or one of the attributes exported by the resource (you can find the list of available attributes in the documentation for each resource). The security group exports an attribute called id, so the expression to reference it will look like this:

```
aws_security_group.instance.id
```

When you add a reference from one resource to another, you create an implicit dependency. Terraform parses these dependencies, builds a dependency graph from them, and uses that to automatically determine in which order it should create resources. For example, if you were deploying this code from scratch, Terraform would know that it needs to create the security group before the EC2 Instance, because the EC2 Instance references the ID of the security group. You can even get Terraform to show you the dependency graph by running the graph command:

![](https://i.imgur.com/HxbxX1s.png)

```
~/Documents/terraform/code/aws-instance-1$ curl 3.144.195.170:8080
Hello, World
```