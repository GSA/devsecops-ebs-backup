data "archive_file" "lambda_ebs_backup_file" {
  type        = "zip"
  source_file = "${path.module}/files/lambda_ebs_backup.py"
  output_path = "${path.module}/files/lambda_ebs_backup.py.zip"
}

data "archive_file" "lambda_ebs_backup_cleaner_file" {
  type        = "zip"
  source_file = "${path.module}/files/lambda_ebs_backup_cleaner.py"
  output_path = "${path.module}/files/lambda_ebs_backup_cleaner.py.zip"
}

# Define Lambda functions
resource "aws_lambda_function" "lambda_ebs_backup_function" {
  filename      = "${path.module}/files/lambda_ebs_backup.py.zip"
  function_name = "${var.lambda_ebs_backup_function_name}"
  role          = "${aws_iam_role.lambda_backup_role.arn}"
  handler       = "lambda_ebs_backup.lambda_handler"
  runtime       = "python3.6"

  environment {
    variables = {
      SNAPSHOT_RETENTION_DAYS = "${var.snapshot_retention_days}"
      SNS_LOG_ARN             = "${aws_sns_topic.ebs_backup_sns.arn}"
      ENVIRONMENT             = "${var.environment}"
    }
  }
}

resource "aws_lambda_function" "lambda_ebs_backup_cleaner" {
  filename      = "${path.module}/files/lambda_ebs_backup_cleaner.py.zip"
  function_name = "${var.lambda_ebs_cleaner_function_name}"
  role          = "${aws_iam_role.lambda_backup_role.arn}"
  handler       = "lambda_ebs_backup_cleaner.lambda_handler"
  runtime       = "python3.6"

  environment {
    variables = {
      SNS_LOG_ARN = "${aws_sns_topic.ebs_backup_sns.arn}"
      ENVIRONMENT = "${var.environment}"
    }
  }
}

# Cloudwatch event rule/target/etc. for the lambda backup function
resource "aws_cloudwatch_event_rule" "ebs_snapshot_event" {
  name                = "${var.ebs_snapshot_event_name}"
  description         = "${var.ebs_snapshot_event_description}"
  schedule_expression = "${var.ebs_snapshot_event_schedule}"
}

resource "aws_cloudwatch_event_target" "lambda_ebs_backup_function_event" {
  rule      = "${aws_cloudwatch_event_rule.ebs_snapshot_event.name}"
  target_id = "lambda_ebs_backup_function"
  arn       = "${aws_lambda_function.lambda_ebs_backup_function.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_ebs_backup_function" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_ebs_backup_function.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ebs_snapshot_event.arn}"
}

# Cloudwatch event rule/target/etc. for the lambda cleaner function
resource "aws_cloudwatch_event_rule" "ebs_snapshot_cleanup_event" {
  name                = "${var.ebs_snapshot_cleanup_event_name}"
  description         = "${var.ebs_snapshot_cleanup_event_description}"
  schedule_expression = "${var.ebs_snapshot_cleanup_event_schedule}"
}

resource "aws_cloudwatch_event_target" "lambda_ebs_backup_cleaner_event" {
  rule      = "${aws_cloudwatch_event_rule.ebs_snapshot_cleanup_event.name}"
  target_id = "lambda_ebs_backup_cleaner"
  arn       = "${aws_lambda_function.lambda_ebs_backup_cleaner.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_ebs_backup_cleaner" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_ebs_backup_cleaner.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ebs_snapshot_cleanup_event.arn}"
}
