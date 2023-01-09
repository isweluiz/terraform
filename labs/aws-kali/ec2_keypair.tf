resource "aws_key_pair" "lab-ansible-key" {
  key_name   = var.ansible_key_name
  public_key = var.ansible_public_key
}

