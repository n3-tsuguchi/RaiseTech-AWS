resource "aws_security_group" "alb" {
  name_prefix = "alb-sg"
  description = "SecurityGroupALB"
  vpc_id      = aws_vpc.raise_tech.id

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "SecurityGroupALB"
  }
}

resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  description       = "Allow HTTP from specified IP"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.cidr_ip]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_egress_all" {
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}


resource "aws_security_group" "ec2" {
  name_prefix = "ec2-sg"
  description = "SecurityGroupEC2"
  vpc_id      = aws_vpc.raise_tech.id

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "SecurityGroupEC2"
  }
}

resource "aws_security_group_rule" "ec2_ttp_from_alb" {
  type                     = "ingress"
  description              = "Allow HTTP from ALB"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "ec2_ssh" {
  type              = "ingress"
  description       = "Allow SSH from specified IP"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.cidr_ip]
  security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "ec2_all" {
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group" "rds" {
  name_prefix = "ads-sg"
  description = "SecurityGroupRDS"
  vpc_id      = aws_vpc.raise_tech.id


  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "SecurityGroupRDS"
  }
}

resource "aws_security_group_rule" "rds_mysql_from_ec2" {
  type                     = "ingress"
  description              = "Allow MySQL from EC2 instances"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2.id
  security_group_id        = aws_security_group.rds.id
}

resource "aws_security_group_rule" "rds_all" {
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds.id
}
