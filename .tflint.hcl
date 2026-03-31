plugin "aws" {
  enabled = true
  version = "0.40.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

config {
  # Evaluate module calls so tflint can follow local module references
  call_module_type = "local"
}
