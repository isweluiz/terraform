output "name" {
  value = [aws_eip.lb.public_ip, aws_instance.aws_instance_01_ubuntu.private_ip]
}