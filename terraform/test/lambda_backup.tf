module "lambda_backup" {
  source                                     = "../"
  environment                                = "${var.environment}"
  lambda_iam_role_name                       = "${var.lambda_iam_role_name}"
  lambda_backup_role_permissions_policy_name = "${var.lambda_backup_role_permissions_policy_name}"
  lambda_ebs_backup_function_name            = "${var.lambda_ebs_backup_function_name}"
  lambda_ebs_cleaner_function_name           = "${var.lambda_ebs_cleaner_function_name}"
  snapshot_retention_days                    = "${var.snapshot_retention_days}"
  snapshot_tag                               = "${var.snapshot_tag}"
  ebs_backup_sns_topic_name                  = "${var.ebs_backup_sns_topic_name}"
  ebs_backup_sns_subscription_address        = "${var.ebs_backup_sns_subscription_address}"
}
