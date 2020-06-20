variable lambda_name {
    description = "A unique name for your Lambda Function."
}

variable lambda_version {
    description = "The version of the lambda function to upload."
}

variable lambda_iam_role_name {
    description = "Name of the IAM role to attach to the lambda."
}

variable lambda_startup_cron {
  description = "Cron rule defining RDS startup time"
}

variable lambda_shutdown_cron {
  description = "Cron rule defining RDS shutdown time"
}

variable rds_instances_identifiers {
  description = "A list of RDS instances identifiers that will be targeted by the lambda."
  type        = list(string)
  default     = []
}

variable rds_instances_tags {
  description = "A mapping of tags used to filter RDS instances that will be targeted by the lambda."
  type        = map(string)
  default     = {}
}

variable tags {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}