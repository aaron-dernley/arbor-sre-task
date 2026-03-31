variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-1"
}

variable "project" {
  description = "Project name, used for naming and tagging all resources"
  type        = string
  default     = "attendance"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "container_image" {
  description = "Docker image for the service"
  type        = string
  default     = "nginx:1.27-alpine"
}

variable "task_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 3
}

variable "alert_email" {
  description = "Email for SLO breach alerts (leave empty to skip)"
  type        = string
  default     = "adernley@gmail.com"
}
