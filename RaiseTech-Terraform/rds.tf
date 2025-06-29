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
  secret_id = aws_secretsmanager_secret.rds_master_user_secret.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.rds_master_password.result
  })
}


resource "aws_db_subnet_group" "raise_tech_rds_subnet_group" {
  name        = "raisetechrdssubnetgroup" 
  description = "RaiseTechDBSubnetGroup"
  subnet_ids  = [
    aws_subnet.private_subnet_1a.id, 
    aws_subnet.private_subnet_1c.id  
  ]

  tags = {
    Name = "RaiseTechDBSubnetGroup"
  }
}

resource "aws_db_instance" "raise_tech_rds" {
  allocated_storage     = 20
  instance_class        = "db.t3.micro"
  port                  = 3306
  storage_type          = "gp2"
  backup_retention_period = 7
  username       = "admin"

  password       = jsondecode(aws_secretsmanager_secret_version.rds_master_user_secret_version.secret_string).password

  identifier            = "raisetech-db" 
  db_name               = "RaiseTechRDS"
  engine                = "mysql"
  engine_version        = "8.0"
  db_subnet_group_name  = aws_db_subnet_group.raise_tech_rds_subnet_group.name
  multi_az              = true
  vpc_security_group_ids = [aws_security_group.security_group_rds.id]

  skip_final_snapshot   = true 

  tags = {
    Name = "RaiseTechRDS"
  }
}