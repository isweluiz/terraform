resource "aws_instance" "aws_instance_01_ubuntu" {
  ami           = "ami-097a2df4ac947655f"
  instance_type = "t2.micro"

  tags = {
    Name = "${var.environment}-${var.service}"
  }
}
