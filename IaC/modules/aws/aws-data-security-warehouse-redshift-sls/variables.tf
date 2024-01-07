variable "vpc_id" {
  description = "vpc id to associate with the redshift security group"
  type        = string
}

variable "s3_bucket_arn" {
  description = "datalake s3 bucket arn"
  type        = string
}

variable "kms_key_arn" {
  description = "kms key arn"
  type        = string
}

variable "Region" {
  description = "region for lambdas deployment"
  type        = string
  default     = "us-east-1"
}

variable "glue_database_name" {
  description = "glue database name"
  type        = string
}

variable "glue_table_prefix" {
  description = "glue table prefix"
  type        = string
}