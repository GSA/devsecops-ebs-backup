variable "environment" {
  type = "string"
}

variable "region" {
  default = "us-east-1"
}

variable "lambda_iam_role_name" {
  default = "ebs-backup-lambda-role"
}

variable "lambda_backup_role_permissions_policy_name" {
  default = "lambda_ebs_backup_permissions"
}

variable "lambda_ebs_backup_function_name" {
  default = "lambda_ebs_backup_function"
}

variable "lambda_ebs_cleaner_function_name" {
  default = "lambda_ebs_retention_function"
}

variable "snapshot_retention_days" {
  default = "14"
}

variable "snapshot_tag" {
  default = "Autosnapshot"
}

variable "ebs_snapshot_event_name" {
  default = "run-at-320"
}

variable "ebs_snapshot_event_description" {
  default = "Runs daily at 3:20am"
}

variable "ebs_snapshot_event_schedule" {
  default = "cron(20 8 * * ? *)"
}

variable "ebs_snapshot_cleanup_event_name" {
  default = "run-at-420"
}

variable "ebs_snapshot_cleanup_event_description" {
  default = "Runs daily at 4:20am"
}

variable "ebs_snapshot_cleanup_event_schedule" {
  default = "cron(20 9 * * ? *)"
}

variable "ebs_backup_sns_topic_name" {
  default = "ebs-backup-topic"
}

variable "ebs_backup_sns_subscription_address" {
  type = "string"
}
