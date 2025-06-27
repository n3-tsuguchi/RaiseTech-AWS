resource "aws_lb" "raise_tech_alb" {
  name               = "RaiseTechALB"
  internal           = false 
  load_balancer_type = "application"
  security_groups    = [aws_security_group.security_group_alb.id] 
  subnets            = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1c.id]

  tags = {
    Name = "${var.prefix}ALB"
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  name     = "ALBTargetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.RaiseTech_vpc.id 
}

resource "aws_lb_target_group_attachment" "ec2_1a_attachment" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.raise_tech_ec2_1a.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "ec2_1c_attachment" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.raise_tech_ec2_1c.id
  port             = 80
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.raise_tech_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}
