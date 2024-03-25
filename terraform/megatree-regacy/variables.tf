# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}
variable "db_password" {
  description = "Gitlab DB password"
  type        = string
  sensitive   = true
}
#variable "bucket_name" {
#  description = "S3 bucket name"
#  type        = string
#  default     = "velero-test-backup-13334"
#}