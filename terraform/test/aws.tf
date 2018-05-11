provider "aws" {
  region = "${var.region}"
  assume_role {
    role_arn = "${var.aws_role_arn}"
  }
}

terraform {
  backend "s3" {}
}
