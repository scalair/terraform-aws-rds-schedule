resource "aws_iam_role" "lambda_iam_role" {
  name = var.lambda_iam_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF

  tags = var.tags
}

resource "aws_iam_role_policy" "lambda_iam_role_policy" {
  role = aws_iam_role.lambda_iam_role.id

  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [ "rds:DescribeDBInstances", "rds:StopDBInstance", "rds:StartDBInstance" ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [ "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents" ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda" {
  function_name = var.lambda_name
  role          = aws_iam_role.lambda_iam_role.arn
  
  runtime = "go1.x"
  timeout = 15

  handler          = "main"
  filename         = "${path.module}/lambda/${var.lambda_version}/rds-schedule.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/${var.lambda_version}/rds-schedule.zip")

  tags = var.tags
}

# Startup rule

resource "aws_cloudwatch_event_rule" "lambda_startup_rule" {
  schedule_expression = format("cron(%s)", var.lambda_startup_cron)
  
  description = "Triggers startup of RDS instances"

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "lambda_startup_target" {
  rule = aws_cloudwatch_event_rule.lambda_startup_rule.name
  arn = aws_lambda_function.lambda.arn

  input = <<EOT
{
  "action": "startup",
  "dbInstancesIdentifiers": ${jsonencode(var.rds_instances_identifiers)},
  "dbInstancesTags": ${jsonencode(var.rds_instances_tags)}
}
EOT
}

resource "aws_lambda_permission" "lambda_startup_permission" {
   action = "lambda:InvokeFunction"
   function_name = aws_lambda_function.lambda.function_name
   principal = "events.amazonaws.com"
   source_arn = aws_cloudwatch_event_rule.lambda_startup_rule.arn
}

# Shutdown rule

resource "aws_cloudwatch_event_rule" "lambda_shutdown_rule" {
  schedule_expression = format("cron(%s)", var.lambda_shutdown_cron)

  description = "Triggers shutdown of RDS instances"

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "lambda_shutdown_target" {
  rule = aws_cloudwatch_event_rule.lambda_shutdown_rule.name
  arn = aws_lambda_function.lambda.arn

  input = <<EOT
{
  "action": "shutdown",
  "dbInstancesIdentifiers": ${jsonencode(var.rds_instances_identifiers)},
  "dbInstancesTags": ${jsonencode(var.rds_instances_tags)}
}
EOT
}

resource "aws_lambda_permission" "lambda_shutdown_permission" {
   action = "lambda:InvokeFunction"
   function_name = aws_lambda_function.lambda.function_name
   principal = "events.amazonaws.com"
   source_arn = aws_cloudwatch_event_rule.lambda_shutdown_rule.arn
}