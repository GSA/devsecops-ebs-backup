resource "aws_sns_topic" "ebs_backup_sns" {
  name = "${var.ebs_backup_sns_topic_name}"
}

resource "null_resource" "subscribe_notification_addresses" {
  count = "${length(var.ebs_backup_sns_subscription_addresses)}"

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${aws_sns_topic.ebs_backup_sns.arn} --protocol email --notification-endpoint ${var.ebs_backup_sns_subscription_addresses[count.index]}"
  }
}
