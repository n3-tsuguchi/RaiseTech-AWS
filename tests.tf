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
