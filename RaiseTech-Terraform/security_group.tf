resource "aws_security_group" "security_group_alb" {
  name        = "SecurityGroupALB"           
  description = "SecurityGroupALB"             
  vpc_id      = aws_vpc.RaiseTech_vpc.id       

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cidr_ip] 
    description = "Allow HTTP from specified IP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" 
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "SecurityGroupALB"
  }
}

resource "aws_security_group" "security_group_ec2" {
  name        = "SecurityGroupEC2"
  description = "SecurityGroupEC2"
  vpc_id      = aws_vpc.RaiseTech_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.security_group_alb.id]
    description = "Allow HTTP from ALB"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_ip]
    description = "Allow SSH from specified IP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "SecurityGroupEC2"
  }
}

resource "aws_security_group" "security_group_rds" {
  name        = "SecurityGroupRDS"
  description = "SecurityGroupRDS"
  vpc_id      = aws_vpc.RaiseTech_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.security_group_ec2.id]
    description = "Allow MySQL from EC2 instances"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "SecurityGroupRDS"
  }
}