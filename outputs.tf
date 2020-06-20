output lambda_iam_role_arn {
    value = aws_iam_role.lambda_iam_role.arn
}

output lambda_arn {
    value = aws_lambda_function.lambda.arn
}

output lambda_version {
    value = aws_lambda_function.lambda.version
}

output lambda_last_modified {
    value = aws_lambda_function.lambda.last_modified
}

output lambda_startup_rule {
    value = aws_cloudwatch_event_rule.lambda_startup_rule
}

output lambda_shutdown_rule {
    value = aws_cloudwatch_event_rule.lambda_shutdown_rule
}