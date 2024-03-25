# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "REGION" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}
variable "AWS_ACCESS_KEY_ID" {
  default = ""
}
variable "AWS_SECRET_ACCESS_KEY" {
  default = ""
}
#variable "bucket_name" {
#  description = "S3 bucket name"
#  type        = string
#  default     = "velero-test-backup-13334"
#}
