output "alb_url" {
  description = "URL of the attendance service"
  value       = "http://${module.alb.dns_name}"
}

output "sns_topic_arn" {
  description = "SNS topic for SLO alerts"
  value       = module.monitoring.sns_topic_arn
}
