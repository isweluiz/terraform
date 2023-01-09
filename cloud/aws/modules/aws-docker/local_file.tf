resource "local_file" "inventory_docker" {
  count = length(aws_instance.docker)
  content = templatefile(
    "${path.module}/ansible_inventory.tftpl",
    {
      user   = "ubuntu"
      prefix = "docker"
      nodes  = aws_instance.docker.*.public_ip
    }
  )
  #filename        = "${path.module}/inventory"
  filename        = "/home/lpereira/Documents/infra-study/gh-actions-docker-py/ansible/docker"
  file_permission = 0744
}

resource "local_file" "inventory_runner" {
  count = length(aws_instance.gh_runner_deploy)
  content = templatefile(
    "${path.module}/ansible_inventory.tftpl",
    {
      user   = "ubuntu"
      prefix = "runner"
      nodes  = aws_instance.gh_runner_deploy.*.public_ip
    }
  )
  filename        = "/home/lpereira/Documents/infra-study/gh-actions-docker-py/ansible/runner"
  file_permission = 0744
}


##### Ansible Output Inventory

#IP of aws instance copied to a file ip.txt in local system
# resource "local_file" "ip" {
#   count           = length(aws_instance.docker)
#   content         = aws_instance.docker[count.index].public_ip
#   filename        = "${path.module}/hosts"
#   file_permission = 0744
# }

# #connecting to the Ansible control node using SSH connection
# resource "null_resource" "nullremote1" {
# depends_on = [aws_instance.os1] 
# connection {
#  type     = "ssh"
#  user     = "root"
#  password = "${var.password}"
#      host= "${var.host}" 
# }
# #copying the ip.txt file to the Ansible control node from local system 
# provisioner "file" {
#     source      = "ip.txt"
#     destination = "/root/ansible_terraform/aws_instance/ip.txt"
#        }
# }

# provisioner "remote-exec" {
#  inline = [
#  "cd /root/ansible_terraform/aws_instance/",
#  "ansible-playbook instance.yml"
# ]
# }