variable "project" {
  description = "Project name prefix for all resources"
  type        = string
}

variable "alert_email" {
  description = "Email for SLO breach alerts (leave empty to skip)"
  type        = string
  default     = ""
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch metrics"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target group ARN suffix for CloudWatch metrics"
  type        = string
}
