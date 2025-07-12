check "alb_configuration" {
  resource "aws_lb" "target" {
    name = aws_lb.raise_tech_alb.name
  }

  assert {
    condition     = self.internal == false
    error_message = "ALB '${self.name}' は internal=true になっています。このALBはパブリックである必要があります。"
  }

  assert {
    condition     = self.load_balancer_type == "application"
    error_message = "ALB '${self.name}' のタイプが '${self.load_balancer_type}' です。'application' である必要があります。"
  }

  assert {
    condition     = length(self.subnets) >= 2
    error_message = "ALB '${self.name}' は ${length(self.subnets)} 個のサブネットにしか配置されていません。高可用性のために2つ以上のサブネットに配置してください。"
  }

  assert {
    condition     = length(self.security_groups) > 0
    error_message = "ALB '${self.name}' にセキュリティグループが設定されていません。"
  }
}

check "target_group_configuration" {

  resource "aws_lb_target_group" "target" {
    name = aws_lb_target_group.alb_tg.name
  }

  assert {
    condition     = self.protocol == "HTTP"
    error_message = "ターゲットグループ '${self.name}' のプロトコルが '${self.protocol}' です。'HTTP' である必要があります。"
  }

  assert {
    condition     = self.port == 80
    error_message = "ターゲットグループ '${self.name}' のポートが ${self.port} です。ポート80である必要があります。"
  }

  assert {
    condition     = self.vpc_id == aws_vpc.raise_tech.id
    error_message = "ターゲットグループ '${self.name}' が意図しないVPC '${self.vpc_id}' に関連付けられています。"
  }
}

check "listener_configuration" {

  resource "aws_lb_listener" "target" {
    load_balancer_arn = aws_lb_listener.alb_listener.load_balancer_arn
    port              = aws_lb_listener.alb_listener.port
  }

  assert {
    condition     = self.protocol == "HTTP"
    error_message = "リスナーのプロトコルが '${self.protocol}' です。'HTTP' である必要があります。"
  }

  assert {
    condition     = self.port == 80
    error_message = "リスナーのポートが ${self.port} です。ポート80である必要があります。"
  }

  assert {
    condition     = self.default_action[0].target_group_arn == aws_lb_target_group.alb_tg.arn
    error_message = "リスナーのデフォルトアクションが、意図しないターゲットグループを向いています。"
  }
}
