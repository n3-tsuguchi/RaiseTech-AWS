resource "aws_sns_topic" "raise_tech_alarm_sns_topic" {
  name         = "${var.prefix}-EC2-CPU-Alarm-Topic" 
  display_name = "RaiseTechEC2AlarmTopic"          

  tags = {
    Name = "${var.prefix}-EC2-CPU-Alarm-Topic" 
  }
}