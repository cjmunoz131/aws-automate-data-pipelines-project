variable "kms_key_id" {
  description = "kms key id"
  type        = string
}

variable "region" {
  type        = string
  description = "deployment region"
  default     = "us-east-1"
}

variable "cross_target_accounts_roles" {
  type = list(object({
    account   = string
    role_name = string
  }))
  description = "set of cross account for access permission set"
  default     = []
}