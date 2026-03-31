locals {
  project = "attendance-prod"
  region  = "eu-west-1"
}

module "networking" {
  source   = "../../modules/networking"
  project  = local.project
  vpc_cidr = "10.0.0.0/16"
}

module "alb" {
  source     = "../../modules/alb"
  project    = local.project
  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.public_subnet_ids
}

module "ecs_service" {
  source                  = "../../modules/ecs-service"
  project                 = local.project
  aws_region              = local.region
  container_image         = "nginx:1.27-alpine"
  task_count              = 3
  vpc_id                  = module.networking.vpc_id
  subnet_ids              = module.networking.private_subnet_ids
  alb_security_group_id   = module.alb.security_group_id
  target_group_arn        = module.alb.target_group_arn
  alb_arn_suffix          = module.alb.arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
}

module "monitoring" {
  source                  = "../../modules/monitoring"
  project                 = local.project
  alert_email             = "adernley@gmail.com"
  alb_arn_suffix          = module.alb.arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
}
