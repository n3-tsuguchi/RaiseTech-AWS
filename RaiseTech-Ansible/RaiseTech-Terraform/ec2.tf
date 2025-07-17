resource "aws_instance" "raise_tech_ec2_1a" {
  ami                         = var.ami_id
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.public_1a.id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  iam_instance_profile        = aws_iam_instance_profile.iam.name
  key_name                    = var.ec2_key_pair_name
  associate_public_ip_address = true
  tags = {
    Name = "${var.prefix}EC21a"
  }
}

resource "aws_instance" "raise_tech_ec2_1c" {
  ami                         = var.ami_id
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.public_1c.id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  iam_instance_profile        = aws_iam_instance_profile.iam.name
  key_name                    = var.ec2_key_pair_name
  associate_public_ip_address = true
  tags = {
    Name = "${var.prefix}EC21c"
  }
}
