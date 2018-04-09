resource "aws_iam_role" "lambda_backup_role" {
  name = "${var.lambda_iam_role_name}"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
            "Service": "lambda.amazonaws.com"
            },
                "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "lambda_backup_role_permissions" {
  name        = "${var.lambda_backup_role_permissions_policy_name}"
  path        = "/"
  description = "Lambda role AWS permissions to take EBS snapshots"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["logs:*"],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:ModifySnapshotAttribute",
        "ec2:ResetSnapshotAttribute",
        "ec2:DeleteSnapshot"
      ],
      "Resource": ["*"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "add_lambda_backup_policy" {
  role       = "${aws_iam_role.lambda_backup_role.name}"
  policy_arn = "${aws_iam_policy.lambda_backup_role_permissions.arn}"
}
