resource "aws_cloudwatch_metric_alarm" "ec2_cpu_alarm_1a" {
  alarm_name          = "${var.prefix}-EC2-CPU-High-Alarm-1a"
  alarm_description   = "${var.prefix}EC21a CPU utilization exceeds 70%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  treat_missing_data  = "notBreaching" 


  dimensions = {
    InstanceId = aws_instance.raise_tech_ec2_1a.id 
  }

  alarm_actions = [aws_sns_topic.raise_tech_alarm_sns_topic.arn]

  ok_actions = [aws_sns_topic.raise_tech_alarm_sns_topic.arn]

  tags = {
    Name = "${var.prefix}-EC2-CPU-High-Alarm-1a"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_alarm_1c" {
  alarm_name          = "${var.prefix}-EC2-CPU-High-Alarm-1c"
  alarm_description   = "${var.prefix}EC21c CPU utilization exceeds 70%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.raise_tech_ec2_1c.id
  }

  alarm_actions = [aws_sns_topic.raise_tech_alarm_sns_topic.arn]

  ok_actions = [aws_sns_topic.raise_tech_alarm_sns_topic.arn]

  tags = {
    Name = "${var.prefix}-EC2-CPU-High-Alarm-1c"
  }
}