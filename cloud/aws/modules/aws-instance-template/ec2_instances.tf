resource "aws_instance" "instance_web_template" {

  count = var.instances_count

  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.ansible_key_name
  associate_public_ip_address = true

  root_block_device {
    delete_on_termination = true
    volume_size           = var.instance_root_disk_size
    volume_type           = var.instance_root_disk_type
  }

  tags = {
    Name = format("%s-%03s.%s.%s.aws.", var.service_name, count.index + 1, var.env, var.aws_main_region)
    env  = var.env
  }
}
