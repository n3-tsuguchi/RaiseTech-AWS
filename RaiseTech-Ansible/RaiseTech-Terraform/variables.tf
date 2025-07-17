variable "cidr_ip" {
  description = "The CIDR IP for MyIP"
  type        = string
}

variable "prefix" {
  description = "The prefix name of the RaiseTech"
  type        = string
  default     = "RaiseTech"
}

variable "ec2_key_pair_name" {
  description = "The name of the EC2 Key Pair for SSH access"
  type        = string
  default     = "kawakami"
}

variable "ec2_instance_type" {
  description = "The instance type for EC2 instances"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "The AMI ID for EC2 instances (ap-northeast-1 region)"
  type        = string
  default     = "ami-0af1df87db7b650f4"
}

variable "aws_managed_policy_parameter01" {
  description = "ARN of IAM Managed Policy to add to the role"
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

variable "s3_bucket_name" {
  description = "Name for the S3 bucket"
  type        = string
}
