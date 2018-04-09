# Define Lambda functions
resource "aws_lambda_function" "lambda_ebs_backup_function" {
  filename      = "${path.module}/files/lambda_ebs_backup.py.zip"
  function_name = "${var.lambda_ebs_backup_function_name}"
  role          = "${aws_iam_role.lambda_backup_role.arn}"
  handler       = "lambda_ebs_backup.lambda_handler"
  runtime       = "python3.6"
}

resource "aws_lambda_function" "lambda_ebs_backup_cleaner" {
  filename      = "${path.module}/files/lambda_ebs_backup_cleaner.py.zip"
  function_name = "${var.lambda_ebs_cleaner_function_name}"
  role          = "${aws_iam_role.lambda_backup_role.arn}"
  handler       = "lambda_ebs_backup_cleaner.lambda_handler"
  runtime       = "python3.6"
}

# Cloudwatch event rule/target/etc. for the lambda backup function
resource "aws_cloudwatch_event_rule" "ebs_snapshot_daily" {
  name                = "run-at-320"
  description         = "Runs daily at 3:20am"
  schedule_expression = "cron(3 20 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_ebs_backup_function_daily" {
  rule      = "${aws_cloudwatch_event_rule.ebs_snapshot_daily.name}"
  target_id = "lambda_ebs_backup_function"
  arn       = "${aws_lambda_function.lambda_ebs_backup_function.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_ebs_backup_function" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_ebs_backup_function.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ebs_snapshot_daily.arn}"
}

# Cloudwatch event rule/target/etc. for the lambda cleaner function
resource "aws_cloudwatch_event_rule" "ebs_snapshot_cleanup_daily" {
  name                = "run-at-420"
  description         = "Runs daily at 4:20am"
  schedule_expression = "cron(4 20 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_ebs_backup_cleaner_daily" {
  rule      = "${aws_cloudwatch_event_rule.ebs_snapshot_cleanup_daily.name}"
  target_id = "lambda_ebs_backup_cleaner"
  arn       = "${aws_lambda_function.lambda_ebs_backup_cleaner.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_ebs_backup_cleaner" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_ebs_backup_cleaner.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ebs_snapshot_cleanup_daily.arn}"
}
