# Terraform AWS RDS Schedule

This module allows to set automatic startup and shutdown schedule based on Lambda and Cloudwatch rules.

## Generating function

The Terraform module is not responsible for packaging the lambda function. This must be done manually by setting version in `lambda/VERSION` and building the function with the command `make`. The packaged functions are versioned alongside the code in `lambda/$VERSION/rds-schedule.zip`.

## How to use it

```hcl
module "rds-schedule" {
  source  = "github.com/scalair/terraform-aws-rds-schedule"
  version = "v1.0.0"
  
  lambda_name          = "rds-schedule-lambda"
  lambda_iam_role_name = "rds-schedule-lambda-role"
  
  # In this case, instances will startup at 7AM and shutdown at 7PM
  lambda_startup_cron  = "0 7 * * 1-5"
  lambda_shutdown_cron = "0 19 * * 1-5"
  
  # If provided, the lambda will target instances that are in that list
  rds_instances_identifiers = [
    "rds-eu-west-1-example1",
    "rds-eu-west-1-example2"
  ]

  # If provided, the lambda will target instances with those tags
  # Note: this is not yet implemented in the lambda
  rds_instances_tags = {
      to-delete = true
  }
  
  tags = {
    terraform   = true
    environment = "dev"
  }
}
```