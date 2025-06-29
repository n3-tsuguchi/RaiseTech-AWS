provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "raise_tech" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "RaiseTech_VPC"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.raise_tech.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet-1a"
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.raise_tech.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true 
  tags = {
    Name = "PublicSubnet-1c"
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id                  = aws_vpc.raise_tech.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false 
  tags = {
    Name = "PrivateSubnet-1a"
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id                  = aws_vpc.raise_tech.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false 
  tags = {
    Name = "PrivateSubnet-1c"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.raise_tech.id
  tags = {
    Name = "InternetGateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.raise_tech.id
  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.raise_tech.id
  tags = {
    Name = "PrivateRouteTable"
  }
}

resource "aws_route_table_association" "public_rt_association_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_rt_association_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_rt_association_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_rt_association_1c" {
  subnet_id      = aws_subnet.private_1c.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_igw.id
}

resource "aws_vpc_endpoint" "s3_gateway_endpoint" {
  vpc_id            = aws_vpc.raise_tech.id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_route_table.id]
  tags = {
    Name = "S3GatewayEndpoint"
  }
}

resource "aws_security_group" "sg_alb" {
  name        = "SecurityGroupALB"
  description = "SecurityGroupALB"
  vpc_id      = aws_vpc.raise_tech.id
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

resource "aws_security_group" "sg_ec2" {
  name        = "SecurityGroupEC2"
  description = "SecurityGroupEC2"
  vpc_id      = aws_vpc.raise_tech.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
    description     = "Allow HTTP from ALB"
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

resource "aws_security_group" "sg_rds" {
  name        = "SecurityGroupRDS"
  description = "SecurityGroupRDS"
  vpc_id      = aws_vpc.raise_tech.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_ec2.id]
    description     = "Allow MySQL from EC2 instances"
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

resource "aws_iam_role" "root_role" {
  name = "RaiseTechEC2Role"
  path = "/"
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

resource "aws_iam_role_policy_attachment" "root_role_policy_attachment" {
  role       = aws_iam_role.root_role.name
  policy_arn = var.aws_managed_policy_parameter01
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "RaiseTechInstanceProfile"
  path = "/"
  role = aws_iam_role.root_role.name
  tags = {
    Name = "RaiseTechInstanceProfile"
  }
}

resource "aws_instance" "raise_tech_ec2_1a" {
  ami                         = var.ami_id
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.public_1a.id
  vpc_security_group_ids      = [aws_security_group.sg_ec2.id]
  iam_instance_profile        = aws_iam_instance_profile.iam_instance_profile.name
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
  vpc_security_group_ids      = [aws_security_group.sg_ec2.id]
  iam_instance_profile        = aws_iam_instance_profile.iam_instance_profile.name
  key_name                    = var.ec2_key_pair_name
  associate_public_ip_address = true
  tags = {
    Name = "${var.prefix}EC21c"
  }
}

resource "aws_lb" "raise_tech_alb" {
  name               = "RaiseTechALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = [aws_subnet.public_1a.id, aws_subnet.public_1c.id]
  tags = {
    Name = "${var.prefix}ALB"
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name     = "ALBTargetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.raise_tech.id
}

resource "aws_lb_target_group_attachment" "ec2_1a_attachment" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.raise_tech_ec2_1a.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "ec2_1c_attachment" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.raise_tech_ec2_1c.id
  port             = 80
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.raise_tech_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_db_subnet_group" "raise_tech_rds_subnet_group" {
  name        = "raisetechrdssubnetgroup" 
  description = "RaiseTechDBSubnetGroup"
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]
  tags = {
    Name = "RaiseTechDBSubnetGroup"
  }
}

resource "random_password" "rds_master_password" {
  length           = 16
  special          = true
  override_special = "!@#$&*()-_=+[]{}|:?./"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "aws_secretsmanager_secret" "rds_master_user_secret" {
  name        = "RDSMasterUserSecret"
  description = "Secret for RDS Master User"
  tags = {
    Name = "RDSMasterUserSecret"
  }
}

resource "aws_secretsmanager_secret_version" "rds_master_user_secret_version" {
  secret_id     = aws_secretsmanager_secret.rds_master_user_secret.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.rds_master_password.result
  })
}

resource "aws_db_instance" "raise_tech_rds" {
  allocated_storage     = 20
  instance_class        = "db.t3.micro"
  port                  = 3306
  storage_type          = "gp2"
  backup_retention_period = 7
  username              = "admin" 
  password              = jsondecode(aws_secretsmanager_secret_version.rds_master_user_secret_version.secret_string).password
  identifier            = "raisetech-db" 
  db_name               = "RaiseTechRDS"
  engine                = "mysql"
  engine_version        = "8.0"
  db_subnet_group_name  = aws_db_subnet_group.raise_tech_rds_subnet_group.name
  multi_az              = true
  vpc_security_group_ids = [aws_security_group.sg_rds.id]
  skip_final_snapshot = true
  tags = {
    Name = "RaiseTechRDS"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_alarm_1a" {
  alarm_name          = "${var.prefix}-EC2-CPU-High-Alarm-1a"
  alarm_description   = "${var.prefix}EC21a CPU utilization exceeds 70%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  treat_missing_data  = "notBreaching"


  dimensions = {
    InstanceId = aws_instance.raise_tech_ec2_1a.id
  }

  alarm_actions = [aws_sns_topic.raise_tech_alarm_sns_topic.arn]

  ok_actions = [aws_sns_topic.raise_tech_alarm_sns_topic.arn]

  tags = {
    Name = "${var.prefix}-EC2-CPU-High-Alarm-1a"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_alarm_1c" {
  alarm_name          = "${var.prefix}-EC2-CPU-High-Alarm-1c"
  alarm_description   = "${var.prefix}EC21c CPU utilization exceeds 70%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.raise_tech_ec2_1c.id
  }

  alarm_actions = [aws_sns_topic.raise_tech_alarm_sns_topic.arn]

  ok_actions = [aws_sns_topic.raise_tech_alarm_sns_topic.arn]

  tags = {
    Name = "${var.prefix}-EC2-CPU-High-Alarm-1c"
  }
}

resource "aws_sns_topic" "raise_tech_alarm_sns_topic" {
  name         = "${var.prefix}-EC2-CPU-Alarm-Topic"
  display_name = "RaiseTechEC2AlarmTopic"

  tags = {
    Name = "${var.prefix}-EC2-CPU-Alarm-Topic"
  }
}