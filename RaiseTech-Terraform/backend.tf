terraform {
  cloud {
    organization = "tsuguchi"

    workspaces {
      name = "tsuguchi-workspace"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
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
  name_prefix = "rds-master-user-"
  description = "Secret for RDS Master User"

  tags = {
    Name = "RDSMasterUserSecret"
  }
}

resource "aws_secretsmanager_secret_version" "rds_master_user_secret_version" {
  secret_id = aws_secretsmanager_secret.rds_master_user_secret.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.rds_master_password.result
  })

  lifecycle {
    ignore_changes = [
      secret_string,
    ]
  }
}

output "generated_password" {
  value     = random_password.rds_master_password.result
  sensitive = true
}

