resource "aws_iam_role" "root_role" {
  name_prefix = "RaiseTechEC2Role"
  path        = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
  tags = {
    Name = "RaiseTechEC2Role"
  }
}

resource "aws_iam_role_policy_attachment" "root_role" {
  role       = aws_iam_role.root_role.name
  policy_arn = var.aws_managed_policy_parameter01
}

resource "aws_iam_instance_profile" "iam" {
  name_prefix = "RaiseTechInstanceProfile"
  path        = "/"
  role        = aws_iam_role.root_role.name
  tags = {
    Name = "RaiseTechInstanceProfile"
  }
}
