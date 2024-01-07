variable "kms_key_arn" {
  type        = string
  description = "kms key arn for bucket s3 encryption"
}

variable "bucket_name" {
  type        = string
  description = "name of the s3 bucket"
}

variable "cross_target_accounts_roles" {
  type = list(object({
    account   = string
    role_name = string
  }))
  description = "set of cross account for access permission set"
  default     = []
}