resource "aws_iam_user" "lb" {
  count = 3

  name = "iam-user${count.index}"
  path = "/system/"

  tags = {
    tag-key = "stage"
  }
}

output "aws_iam_user" {
  value = ["${aws_iam_user.lb[*].name}"]
}


resource "aws_iam_access_key" "lb" {
  user = aws_iam_user.lb[*]
}

/*
resource "aws_iam_user_policy" "lb_ro" {
  name = "iam-user-policy"
  user = aws_iam_user.lb[*].name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
*/