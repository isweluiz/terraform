resource "aws_eip" "lb" {
  #instance = aws_instance.aws_instance_01_ubuntu.id
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.aws_instance_01_ubuntu.id
  allocation_id = aws_eip.lb.id
}