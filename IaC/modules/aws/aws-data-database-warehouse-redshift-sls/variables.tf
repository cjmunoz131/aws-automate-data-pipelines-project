variable "redshift_serverless_namespace_name" {
  type = string
}

variable "redshift_serverless_database_name" {
  type = string
}

variable "redshift_serverless_admin_username" {
  type = string
}

variable "redshift_serverless_admin_password" {
  type = string
}

variable "redshift_serverless_iam_role_arn" {
  type = string
}

variable "redshift_serverless_workgroup_name" {
  type = string
}

variable "redshift_serverless_base_capacity" {
  type = number
}

variable "redshift_serverless_sg_id" {
  type = string
}

variable "redshift_serverless_publicly_accessible" {
  type    = bool
  default = false
}

variable "subnets_id" {
  type = set(string)
}

variable "kms_key_id" {
  type = string
}

variable "enhanced_vpc_routing_enabled" {
  type = bool
}