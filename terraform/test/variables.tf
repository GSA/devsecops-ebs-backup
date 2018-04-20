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
