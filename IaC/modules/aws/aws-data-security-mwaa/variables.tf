variable "source_bucket_arn" {
  type        = string
  description = "s3 bucket for mwaa usage"
}

variable "name_mwaa_env" {
  type        = string
  description = "name for mwaa environment"
}

variable "kms_key" {
  type        = string
  description = "cmk key encryption"
}

variable "iam_role_name" {
  type        = string
  description = "name for the mwaa execution role"
}

variable "iam_role_path" {
  type        = string
  description = "iam role path"
}

variable "iam_role_additional_policies" {
  type        = set(string)
  description = "set of the aws managed policies arns"
}

variable "vpc_id" {
  type        = string
  description = "id of the vpc where is associated the security group"
}