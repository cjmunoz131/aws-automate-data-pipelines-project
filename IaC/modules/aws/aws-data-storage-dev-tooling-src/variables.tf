variable "kms_key_arn" {
  description = "kms key for the s3 object encryption"
  type        = string
}

variable "source_location_s3_subdirectory" {
  type = string
}

variable "dev_tooling_bucket_name" {
  type        = string
  description = "bucket name for dev tooling storage unique in the account"
}