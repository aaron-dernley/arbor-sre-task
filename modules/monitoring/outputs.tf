output "sns_topic_arn" {
  description = "SNS topic ARN for SLO alerts"
  value       = aws_sns_topic.alerts.arn
}
