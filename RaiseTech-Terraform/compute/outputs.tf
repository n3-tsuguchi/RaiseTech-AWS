output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.raise_tech.id
}

output "public_subnet_1a_id" {
  description = "The ID of Public Subnet 1a"
  value       = aws_subnet.public_1a.id
}

output "public_subnet_1c_id" {
  description = "The ID of Public Subnet 1c"
  value       = aws_subnet.public_1c.id
}

output "private_subnet_1a_id" {
  description = "The ID of Private Subnet 1a"
  value       = aws_subnet.private_1a.id
}

output "private_subnet_1c_id" {
  description = "The ID of Private Subnet 1c"
  value       = aws_subnet.private_1c.id
}

output "internet_gateway_id" {
  description = "The ID of the created Internet Gateway"
  value       = aws_internet_gateway.main_igw.id
}

output "public_route_table_id" {
  description = "The ID of the Public Route Table"
  value       = aws_route_table.public_route_table.id
}

output "private_route_table_id" {
  description = "The ID of the Private Route Table"
  value       = aws_route_table.private_route_table.id
}

output "s3_gateway_endpoint_id" {
  description = "The ID of the S3 Gateway VPC Endpoint"
  value       = aws_vpc_endpoint.s3_gateway_endpoint.id
}

output "security_group_alb_id" {
  description = "The ID of the Security Group for ALB"
  value       = aws_security_group.sg_alb.id
}

output "security_group_ec2_id" {
  description = "The ID of the Security Group for EC2"
  value       = aws_security_group.sg_ec2.id
}

output "security_group_rds_id" {
  description = "The ID of the Security Group for RDS"
  value       = aws_security_group.sg_rds.id
}

output "iam_role_arn" {
  description = "The ARN of the created IAM Role"
  value       = aws_iam_role.root_role.arn
}

output "iam_instance_profile_name" {
  description = "The Name of the created IAM Instance Profile"
  value       = aws_iam_instance_profile.iam_instance_profile.name
}

output "raise_tech_ec2_1a_id" {
  description = "The ID of RaiseTechEC21a instance"
  value       = aws_instance.raise_tech_ec2_1a.id
}

output "raise_tech_ec2_1a_public_ip" {
  description = "The Public IP of RaiseTechEC21a instance"
  value       = aws_instance.raise_tech_ec2_1a.public_ip
}

output "raise_tech_ec2_1c_id" {
  description = "The ID of RaiseTechEC21c instance"
  value       = aws_instance.raise_tech_ec2_1c.id
}

output "raise_tech_ec2_1c_public_ip" {
  description = "The Public IP of RaiseTechEC21c instance"
  value       = aws_instance.raise_tech_ec2_1c.public_ip
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.raise_tech_alb.dns_name
}

output "alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.raise_tech_alb.arn
}

output "alb_target_group_arn" {
  description = "The ARN of the ALB Target Group"
  value       = aws_lb_target_group.alb_tg.arn
}

output "rds_master_user_secret_name" {
  description = "The name of the RDS Master User Secret in Secrets Manager"
  value       = aws_secretsmanager_secret.rds_master_user_secret.name
}

output "rds_db_instance_endpoint" {
  description = "The endpoint of the RDS DB Instance"
  value       = aws_db_instance.raise_tech_rds.address
}

output "rds_db_instance_port" {
  description = "The port of the RDS DB Instance"
  value       = aws_db_instance.raise_tech_rds.port
}

output "rds_db_subnet_group_name" {
  description = "The name of the RDS DB Subnet Group"
  value       = aws_db_subnet_group.raise_tech_rds_subnet_group.name
}

output "sns_topic_arn" {
  description = "The ARN of the SNS Topic for CloudWatch Alarms"
  value       = aws_sns_topic.raise_tech_alarm_sns_topic.arn
}

output "ec2_cpu_alarm_1a_name" {
  description = "The name of the EC2 CPU Alarm for instance 1a"
  value       = aws_cloudwatch_metric_alarm.ec2_cpu_alarm_1a.alarm_name
}

output "ec2_cpu_alarm_1c_name" {
  description = "The name of the EC2 CPU Alarm for instance 1c"
  value       = aws_cloudwatch_metric_alarm.ec2_cpu_alarm_1c.alarm_name
}