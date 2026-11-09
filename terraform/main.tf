resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "portfolio-ec2-observability"
  dashboard_body = jsonencode({
    widgets = [{
      type = "metric", x = 0, y = 0, width = 12, height = 6,
      properties = {
        metrics = [["AWS/EC2", "CPUUtilization", "InstanceId", var.instance_id]]
        period = 300, stat = "Average", region = var.aws_region,
        title = "EC2 CPU Utilization"
      }
    }]
  })
}
resource "aws_sns_topic" "alerts" { count = var.alarm_email == "" ? 0 : 1, name = "portfolio-ec2-alerts" }
resource "aws_sns_topic_subscription" "email" {
  count = var.alarm_email == "" ? 0 : 1
  topic_arn = aws_sns_topic.alerts[0].arn
  protocol = "email"
  endpoint = var.alarm_email
}
resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name = "portfolio-ec2-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 300
  statistic = "Average"
  threshold = 80
  alarm_description = "Average CPU above 80% for two periods."
  dimensions = { InstanceId = var.instance_id }
  alarm_actions = var.alarm_email == "" ? [] : [aws_sns_topic.alerts[0].arn]
}
output "dashboard_name" { value = aws_cloudwatch_dashboard.main.dashboard_name }
output "alarm_name" { value = aws_cloudwatch_metric_alarm.cpu.alarm_name }
