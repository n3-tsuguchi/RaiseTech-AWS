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
