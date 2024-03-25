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

variable "TFC_OGANIZATION_NAME" {
  type    = string
  default = "project-org"
}

variable "TFC_TOKEN" {
  type        = string
  default     = ""
  description = "TFC_TOKEN"
}

variable "NETWORK_DMZ_WORKSPACE_NAME" {
  type    = string
  default = ""
}
variable "NETWORK_APP_WORKSPACE_NAME" {
  type    = string
  default = ""
}

variable "NETWORK_SHARE_WORKSPACE_NAME" {
  type    = string
  default = ""
}