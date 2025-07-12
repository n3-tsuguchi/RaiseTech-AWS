check "vpc_configuration" {
  
  assert {
    condition     = aws_vpc.raise_tech.cidr_block == "10.0.0.0/16"
    error_message = "VPCのCIDRブロックが'${aws_vpc.raise_tech.cidr_block}'になっています。'10.0.0.0/16'であるべきです。"
  }
}

check "subnets_configuration" {
 
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

check "routing_configuration" {
  
  assert {
    condition = anytrue([
      for route in aws_route_table.public_route_table.routes :
      route.destination_cidr_block == "0.0.0.0/0" && route.gateway_id == aws_internet_gateway.main_igw.id
    ])
    error_message = "パブリックルートテーブルに、インターネットゲートウェイへのデフォルトルート(0.0.0.0/0)が存在しません。"
  }

  assert {
    condition = alltrue([
      for route in aws_route_table.private_route_table.routes :
      route.gateway_id != aws_internet_gateway.main_igw.id
    ])
    error_message = "セキュリティリスク: プライベートルートテーブルからインターネットゲートウェイへの直接ルートが見つかりました。"
  }
}

check "s3_vpc_endpoint_configuration" {
  
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

check "ec2_instance_configuration" {

  assert {
    condition     = aws_instance.raise_tech_ec2_1a.ami == var.ami_id
    error_message = "EC2インスタンス'${aws_instance.raise_tech_ec2_1a.tags.Name}'のAMI IDが、変数で指定された値と異なります。"
  }

  assert {
    condition     = aws_instance.raise_tech_ec2_1a.instance_type == var.ec2_instance_type
    error_message = "EC2インスタンス'${aws_instance.raise_tech_ec2_1a.tags.Name}'のインスタンスタイプが、変数で指定された値と異なります。"
  }

  assert {
    condition     = aws_instance.raise_tech_ec2_1a.associate_public_ip_address == true
    error_message = "EC2インスタンス'${aws_instance.raise_tech_ec2_1a.tags.Name}'でパブリックIPアドレスの自動割り当てが無効になっています。"
  }

  assert {
    condition     = aws_instance.raise_tech_ec2_1a.iam_instance_profile == aws_iam_instance_profile.iam.name
    error_message = "EC2インスタンス'${aws_instance.raise_tech_ec2_1a.tags.Name}'に予期しないIAMインスタンスプロファイルがアタッチされています。"
  }

  assert {
    condition     = aws_instance.raise_tech_ec2_1a.subnet_id == aws_subnet.public_1a.id
    error_message = "EC2インスタンス'${aws_instance.raise_tech_ec2_1a.tags.Name}'が予期しないサブネットに配置されています。"
  }

  assert {
    condition     = aws_instance.raise_tech_ec2_1c.ami == var.ami_id
    error_message = "EC2インスタンス'${aws_instance.raise_tech_ec2_1c.tags.Name}'のAMI IDが、変数で指定された値と異なります。"
  }

  assert {
    condition     = aws_instance.raise_tech_ec2_1c.instance_type == var.ec2_instance_type
    error_message = "EC2インスタンス'${aws_instance.raise_tech_ec2_1c.tags.Name}'のインスタンスタイプが、変数で指定された値と異なります。"
  }

  assert {
    condition     = aws_instance.raise_tech_ec2_1c.associate_public_ip_address == true
    error_message = "EC2インスタンス'${aws_instance.raise_tech_ec2_1c.tags.Name}'でパブリックIPアドレスの自動割り当てが無効になっています。"
  }

  assert {
    condition     = aws_instance.raise_tech_ec2_1c.iam_instance_profile == aws_iam_instance_profile.iam.name
    error_message = "EC2インスタンス'${aws_instance.raise_tech_ec2_1c.tags.Name}'に予期しないIAMインスタンスプロファイルがアタッチされています。"
  }

  assert {
    condition     = aws_instance.raise_tech_ec2_1c.subnet_id == aws_subnet.public_1c.id
    error_message = "EC2インスタンス'${aws_instance.raise_tech_ec2_1c.tags.Name}'が予期しないサブネットに配置されています。"
  }
}

check "alb_configuration" {

  assert {
    condition     = aws_lb.raise_tech_alb.internal == false
    error_message = "ALB '${aws_lb.raise_tech_alb.name}' は internal=true になっています。このALBはパブリックである必要があります。"
  }

  assert {
    condition     = aws_lb.raise_tech_alb.load_balancer_type == "application"
    error_message = "ALB '${aws_lb.raise_tech_alb.name}' のタイプが '${aws_lb.raise_tech_alb.load_balancer_type}' です。'application' である必要があります。"
  }

  assert {
    condition     = length(aws_lb.raise_tech_alb.subnets) >= 2
    error_message = "ALB '${aws_lb.raise_tech_alb.name}' は ${length(aws_lb.raise_tech_alb.subnets)} 個のサブネットにしか配置されていません。高可用性のために2つ以上のサブネットに配置してください。"
  }

  assert {
    condition     = length(aws_lb.raise_tech_alb.security_groups) > 0
    error_message = "ALB '${aws_lb.raise_tech_alb.name}' にセキュリティグループが設定されていません。"
  }
}

check "target_group_configuration" {

  assert {
    condition     = aws_lb_target_group.alb_tg.protocol == "HTTP"
    error_message = "ターゲットグループ '${aws_lb_target_group.alb_tg.name}' のプロトコルが '${aws_lb_target_group.alb_tg.protocol}' です。'HTTP' である必要があります。"
  }

  assert {
    condition     = aws_lb_target_group.alb_tg.port == 80
    error_message = "ターゲットグループ '${aws_lb_target_group.alb_tg.name}' のポートが ${aws_lb_target_group.alb_tg.port} です。ポート80である必要があります。"
  }

  assert {
    condition     = aws_lb_target_group.alb_tg.vpc_id == aws_vpc.raise_tech.id
    error_message = "ターゲットグループ '${aws_lb_target_group.alb_tg.name}' が意図しないVPC '${aws_lb_target_group.alb_tg.vpc_id}' に関連付けられています。"
  }
}

check "listener_configuration" {

  assert {
    condition     = aws_lb_listener.alb_listener.protocol == "HTTP"
    error_message = "リスナーのプロトコルが '${aws_lb_listener.alb_listener.protocol}' です。'HTTP' である必要があります。"
  }

  assert {
    condition     = aws_lb_listener.alb_listener.port == 80
    error_message = "リスナーのポートが ${aws_lb_listener.alb_listener.port} です。ポート80である必要があります。"
  }

  assert {
    condition     = aws_lb_listener.alb_listener.default_action[0].target_group_arn == aws_lb_target_group.alb_tg.arn
    error_message = "リスナーのデフォルトアクションが、意図しないターゲットグループを向いています。"
  }
}

check "db_subnet_group_configuration" {
  
  assert {
    condition     = length(aws_db_subnet_group.raise_tech_rds.subnet_ids) >= 2
    error_message = "DBサブネットグループ'${aws_db_subnet_group.raise_tech_rds.name}'には、サブネットが1つしか登録されていません。高可用性のために2つ以上登録してください。"
  }

  assert {
    condition = alltrue([
      for subnet_id in aws_db_subnet_group.raise_tech_rds.subnet_ids :
      contains([aws_subnet.private_1a.id, aws_subnet.private_1c.id], subnet_id)
    ])
    error_message = "DBサブネットグループ'${aws_db_subnet_group.raise_tech_rds.name}'に、プライベートサブネット以外のものが含まれています。"
  }
}

check "db_instance_configuration" {

  assert {
    condition     = aws_db_instance.raise_tech_rds.instance_class == "db.t3.micro"
    error_message = "RDSインスタンス'${aws_db_instance.raise_tech_rds.identifier}'のインスタンスクラスが'${aws_db_instance.raise_tech_rds.instance_class}'です。'db.t3.micro'であるべきです。"
  }

  assert {
    condition     = aws_db_instance.raise_tech_rds.engine == "mysql" && aws_db_instance.raise_tech_rds.engine_version == "8.0"
    error_message = "RDSインスタンス'${aws_db_instance.raise_tech_rds.identifier}'のエンジンが'${aws_db_instance.raise_tech_rds.engine} v${aws_db_instance.raise_tech_rds.engine_version}'です。'mysql v8.0'であるべきです。"
  }

  assert {
    condition     = aws_db_instance.raise_tech_rds.multi_az == true
    error_message = "RDSインスタンス'${aws_db_instance.raise_tech_rds.identifier}'のマルチAZが無効になっています。可用性のために有効にしてください。"
  }

  assert {
    condition     = aws_db_instance.raise_tech_rds.backup_retention_period >= 7
    error_message = "RDSインスタンス'${aws_db_instance.raise_tech_rds.identifier}'のバックアップ保持期間が${aws_db_instance.raise_tech_rds.backup_retention_period}日です。データの保全のために7日以上に設定してください。"
  }

  assert {
    condition     = aws_db_instance.raise_tech_rds.skip_final_snapshot == true
    error_message = "RDSインスタンス'${aws_db_instance.raise_tech_rds.identifier}'の最終スナップショットが有効になっています。"
  }

  assert {
    condition     = aws_db_instance.raise_tech_rds.username == "admin"
    error_message = "RDSインスタンス'${aws_db_instance.raise_tech_rds.identifier}'のマスターユーザー名が'${aws_db_instance.raise_tech_rds.username}'です。'admin'であるべきです。"
  }

  assert {
    condition     = jsondecode(aws_secretsmanager_secret_version.rds_version.secret_string).password == aws_db_instance.raise_tech_rds.password
    error_message = "RDSインスタンスのパスワードがSecrets Managerで管理されている値と一致しません。"
  }
}
