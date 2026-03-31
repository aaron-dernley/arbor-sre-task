output "alb_url" {
  description = "URL of the attendance service"
  value       = "http://${aws_lb.main.dns_name}"
}

output "sns_topic_arn" {
  description = "SNS topic for SLO alerts"
  value       = aws_sns_topic.alerts.arn
}
