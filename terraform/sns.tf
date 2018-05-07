resource "aws_sns_topic" "ebs_backup_sns" {
  name = "${var.ebs_backup_sns_topic_name}"

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.ebs_backup_sns_subscription_address}"
  }
}
