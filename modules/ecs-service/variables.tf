variable "project" {
  description = "Project name prefix for all resources"
  type        = string
}

variable "aws_region" {
  description = "AWS region (used for CloudWatch log configuration)"
  type        = string
}

variable "container_image" {
  description = "Docker image for the service"
  type        = string
}

variable "task_count" {
  description = "Desired (and minimum) number of ECS tasks"
  type        = number
}

variable "vpc_id" {
  description = "VPC ID to deploy into"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ALB security group ID (ECS ingress rule)"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN to register tasks with"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for auto-scaling metric"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target group ARN suffix for auto-scaling metric"
  type        = string
}
