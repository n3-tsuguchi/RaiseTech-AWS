resource "aws_lb" "raise_tech_alb" {
  name               = "RaiseTechALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
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

resource "aws_lb_target_group_attachment" "ec2_1a_at" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.raise_tech_ec2_1a.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "ec2_1c_at" {
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
