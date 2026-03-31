# Classroom Attendance Service

Infrastructure for an nginx attendance service on AWS, managed with Terraform.

---

## Repository structure

```
.
├── modules/                   # Reusable building blocks
│   ├── networking/            # VPC, subnets, internet gateway, NAT, routing
│   ├── alb/                   # Application load balancer, target group, listener
│   ├── ecs-service/           # ECS cluster, task definition, service, autoscaling
│   └── monitoring/            # CloudWatch alarms, SNS topic
│
├── environments/              # Per-environment compositions
│   ├── dev/                   # 1 task, no alerts, CIDR 10.1.0.0/16
│   ├── preprod/               # 2 tasks, no alerts, CIDR 10.2.0.0/16
│   └── prod/                  # 3 tasks, email alerts, CIDR 10.0.0.0/16
│
└── (root)                     # Original flat module, backs existing state
```

### How modularisation works

Each directory under `modules/` is a self-contained Terraform module — it declares its inputs (`variables.tf`), creates resources (`main.tf`), and exposes outputs (`outputs.tf`). Modules have no knowledge of each other.

Each directory under `environments/` is a root module that composes the four building blocks together. It calls each module, passing outputs from one as inputs to the next:

```
networking ──► alb ──► ecs-service
    │                      │
    └──────────────────────┘
              │
          monitoring
```

For example, `environments/prod/main.tf` wires them like this:

```hcl
module "networking" {
  source   = "../../modules/networking"
  project  = "attendance-prod"
  vpc_cidr = "10.0.0.0/16"
}

module "alb" {
  source     = "../../modules/alb"
  vpc_id     = module.networking.vpc_id        # output from networking
  subnet_ids = module.networking.public_subnet_ids
  ...
}

module "ecs_service" {
  source                = "../../modules/ecs-service"
  vpc_id                = module.networking.vpc_id
  subnet_ids            = module.networking.private_subnet_ids
  alb_security_group_id = module.alb.security_group_id  # output from alb
  target_group_arn      = module.alb.target_group_arn
  ...
}

module "monitoring" {
  source                  = "../../modules/monitoring"
  alb_arn_suffix          = module.alb.arn_suffix        # output from alb
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  ...
}
```

This means:
- **Modules are never applied directly** — only environments are. Each environment has its own isolated state.
- **Changing a module affects every environment that uses it**, which is why changes flow through dev → preprod → prod.
- **Environments differ only in their inputs** — task count, CIDR, alert email — the underlying infrastructure logic lives once in the modules.

---

## Working with an environment

All commands are run from inside the environment directory:

```bash
cd environments/prod   # or dev, preprod

terraform init         # download providers, initialise state
terraform plan         # preview changes
terraform apply        # create / update infrastructure
terraform destroy      # tear everything down
terraform output alb_url   # get the service URL after apply
```

---

## CI

GitHub Actions runs on every pull request:

| Job | Tool | What it checks |
|---|---|---|
| Format check | `terraform fmt` | All `.tf` files are canonically formatted |
| Lint | `tflint` | Deprecated arguments, invalid types, unused variables |
| Validate | `terraform validate` | Module wiring is valid HCL (runs per environment) |
| Security scan | `checkov` | Misconfigurations against CIS/NIST benchmarks |

---

## Load test

```bash
hey -z 120s -c 200 -q 30 <alb_url>  # 6,000 req/s for 2 minutes
hey -z 300s -c 500 -q 20 <alb_url>  # ~10,000 req/s for 5 minutes — triggers autoscaling
```
