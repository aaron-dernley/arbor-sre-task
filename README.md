# Classroom Attendance Service

Creating Infrastructure to host an nginx 'attendance' service on AWS - with Terraform.

## Let's go!

```bash
terraform fmt - formatting
terraform validate - checks files for invalid syntax etc.
terraform plan - what exactly will be created/changed/destroyed
terraform apply - create the infrastructure
terraform output alb_url - get the alb url for the load tests
terraform destroy - remove everything - dont forget to do this!!!
```

## Load test

```bash
hey -z 120s -c 200 -q 30 alb_url # Hit at exactly 6,000 req/s for 2 minutes

hey -z 300s -c 500 -q 20 alb_url # Overwhelm it at ~10,000 req/s for 5 minutes to trigger auto-scaling
```
