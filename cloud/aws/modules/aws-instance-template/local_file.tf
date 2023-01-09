resource "local_file" "inventory" {
  count           = length(aws_instance.instance_web_template)
  content         = templatefile(
                    "${path.module}/ansible_inventory.tftpl",
                        { 
                            user = "ubuntu"
                            prefix = "swarm"
                            nodes = aws_instance.instance_web_template.*.public_ip
                        }
                     )
  filename        = "${path.module}/inventory"
  file_permission = 0744
}

##### Ansible Output Inventory

#IP of aws instance copied to a file ip.txt in local system
# resource "local_file" "ip" {
#   count           = length(aws_instance.instance_web_template)
#   content         = aws_instance.instance_web_template[count.index].public_ip
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