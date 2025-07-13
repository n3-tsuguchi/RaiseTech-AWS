variables {
  cidr_ip           = "10.0.0.0/16"
  s3_bucket_name    = "my-test-bucket-for-raisetech"
  ami_id            = "ami-0c55b159cbfafe1f0"
  ec2_instance_type = "t2.micro"
  ec2_key_pair_name = "kawakami"
  prefix            = "test-"
}

run "vpc_configuration" {
  command = plan

  assert {
    condition     = aws_vpc.raise_tech.cidr_block == "10.0.0.0/16"
    error_message = "VPCのCIDRブロックが'${aws_vpc.raise_tech.cidr_block}'になっています。'10.0.0.0/16'であるべきです。"
  }
}

run "subnets_configuration" {
  command = plan

  assert {
    condition     = aws_subnet.public_1a.map_public_ip_on_launch == true
    error_message = "パブリックサブネット'${aws_subnet.public_1a.tags.Name}'で、パブリックIPの自動割り当てが無効になっています。"
  }
  assert {
    condition     = aws_subnet.public_1c.map_public_ip_on_launch == true
    error_message = "パブリックサブネット'${aws_subnet.public_1c.tags.Name}'で、パブリックIPの自動割り当てが無効になっています。"
  }
  assert {
    condition     = aws_subnet.private_1a.map_public_ip_on_launch == false
    error_message = "プライベートサブネット'${aws_subnet.private_1a.tags.Name}'で、パブリックIPの自動割り当てが有効になっています。"
  }
  assert {
    condition     = aws_subnet.private_1c.map_public_ip_on_launch == false
    error_message = "プライベートサブネット'${aws_subnet.private_1c.tags.Name}'で、パブリックIPの自動割り当てが有効になっています。"
  }
}

run "s3_vpc_endpoint_configuration" {
  command = plan

  assert {
    condition     = aws_vpc_endpoint.s3_gateway_endpoint.vpc_id == aws_vpc.raise_tech.id
    error_message = "S3ゲートウェイエンドポイントが予期しないVPCに接続されています。"
  }
  assert {
    condition     = aws_vpc_endpoint.s3_gateway_endpoint.vpc_endpoint_type == "Gateway"
    error_message = "S3エンドポイントのタイプが'${aws_vpc_endpoint.s3_gateway_endpoint.vpc_endpoint_type}'です。'Gateway'タイプであるべきです。"
  }
  assert {
    condition     = contains(aws_vpc_endpoint.s3_gateway_endpoint.route_table_ids, aws_route_table.private_route_table.id)
    error_message = "S3ゲートウェイエンドポイントがプライベートルートテーブルに関連付けられていません。"
  }
}

run "ec2_instance_configuration" {
  command = plan

  assert {
    condition     = aws_instance.raise_tech_ec2_1a.ami == var.ami_id
    error_message = "EC2インスタンス'${aws_instance.raise_tech_ec2_1a.tags.Name}'のAMI IDが、変数で指定された値と異なります。"
  }
  assert {
    condition     = aws_instance.raise_tech_ec2_1a.instance_type == var.ec2_instance_type
    error_message = "EC2インスタンス'${aws_instance.raise_tech_ec2_1a.tags.Name}'のインスタンスタイプが、変数で指定された値と異なります。"
  }
}

run "alb_and_listener_configuration" {
  command = plan

  assert {
    condition     = aws_lb.raise_tech_alb.internal == false
    error_message = "ALB '${aws_lb.raise_tech_alb.name}' は internal=true になっています。このALBはパブリックである必要があります。"
  }
  assert {
    condition     = aws_lb.raise_tech_alb.load_balancer_type == "application"
    error_message = "ALB '${aws_lb.raise_tech_alb.name}' のタイプが '${aws_lb.raise_tech_alb.load_balancer_type}' です。'application' である必要があります。"
  }
  assert {
    condition     = aws_lb_listener.alb_listener.protocol == "HTTP"
    error_message = "リスナーのプロトコルが '${aws_lb_listener.alb_listener.protocol}' です。'HTTP' である必要があります。"
  }
}

run "db_subnet_group_configuration" {
  command = plan

  assert {
    condition     = length(aws_db_subnet_group.raise_tech_rds.subnet_ids) >= 2
    error_message = "DBサブネットグループ'${aws_db_subnet_group.raise_tech_rds.name}'には、サブネットが1つしか登録されていません。高可用性のために2つ以上登録してください。"
  }
}

run "db_instance_configuration" {
  command = plan

  assert {
    condition     = aws_db_instance.raise_tech_rds.instance_class == "db.t3.micro"
    error_message = "RDSインスタンス'${aws_db_instance.raise_tech_rds.identifier}'のインスタンスクラスが'${aws_db_instance.raise_tech_rds.instance_class}'です。'db.t3.micro'であるべきです。"
  }
  assert {
    condition     = aws_db_instance.raise_tech_rds.multi_az == true
    error_message = "RDSインスタンス'${aws_db_instance.raise_tech_rds.identifier}'のマルチAZが無効になっています。可用性のために有効にしてください。"
  }
  assert {
    condition     = aws_db_instance.raise_tech_rds.backup_retention_period >= 7
    error_message = "RDSインスタンス'${aws_db_instance.raise_tech_rds.identifier}'のバックアップ保持期間が${aws_db_instance.raise_tech_rds.backup_retention_period}日です。データの保全のために7日以上に設定してください。"
  }
}
