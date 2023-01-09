output "public_ip" {
  value = aws_instance.instance_web_template.*.public_ip
}

