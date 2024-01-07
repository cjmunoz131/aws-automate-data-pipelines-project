variable "bucket_assests_name" {
  type = string
}

variable "kms_key_arn" {
  type = string
}

variable "datasync-s3-source-role" {
  type = string
}

variable "cross_target_accounts_roles" {
  type = list(object({
    account   = string
    role_name = string
  }))
  description = "set of cross account for access permission set"
  default     = []
}

variable "source_location_s3_subdirectory" {
  type = string
}