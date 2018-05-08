# devsecops-ebs-backup [![CircleCI](https://circleci.com/gh/GSA/devsecops-ebs-backup.svg?style=svg)](https://circleci.com/gh/GSA/devsecops-ebs-backup)

This is a quick implementation of an EBS backup solution with Terraform and Lambda.

It can be executed out of the box by installing Terraform and running the deployment steps below.

## Test Deployment

Use these steps to deploy the test.

1. Create an S3 bucket for the terraform state.
1. Run the following command:

    ````sh
    cd terraform/test
    cp backend.tfvars.example backend.tfvars
    cp terraform.tfvars.example terraform.tfvars
    ````

1. Fill out backend.tfvars with the name of the S3 bucket you just created.
1. Fill out terraform.tfvars with required values. At a minimum, required variables for this repo are "environment" and "ebs_backup_sns_subscription_address". Both are type "string."
1. Run the init:

    ````sh
    terraform init --backend-config="backend.tfvars"
    ````

1. Run a plan to make sure everything is fine and ready to go:

    ````sh
    terraform plan
    ````

1. If there are no issues, apply the stack:

    ````sh
    terraform apply
    ````

The address that was configured in the variable "ebs_backup_sns_subscription_address" will be asked to confirm the SNS subscription in email. You MUST confirm with the link in the email to receive notifications from the Lambda scripts.

## Attribution

The lambda function code used in this terraform module is adapted from [this link](https://serverlesscode.com/post/lambda-schedule-ebs-snapshot-backups-2/)