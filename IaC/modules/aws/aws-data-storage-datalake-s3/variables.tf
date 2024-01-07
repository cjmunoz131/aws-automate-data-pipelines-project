# Common Settings
variable "bucket_datalake_name" {
  description = "Prefix used to name all resources created by this CloudFormation template. Use 3 alphanumeric characters only. Cannot be 'aws'. e.g. department name, business unit, project name"
  type        = string
  default     = "datalake-stedi"
}
variable "EnvironmentCode" {
  description = "Code used to name all resources created by this CloudFormation template. Use 2 alphanumeric characters only. E.g. 'pd' for production"
  type        = string
  default     = "dev"
}
variable "OwnerTag" {
  description = "FinOps"
  type        = string
  default     = "pragma"
}
variable "EnvironmentTag" {
  description = "Environment tag value. All resources are created with an 'Environment' tag and the value you set here. e.g. production, staging, development"
  type        = string
  default     = "Production"
}

variable "Region" {
  description = "region for lambdas deployment"
  type        = string
  default     = "us-east-1"
}

variable "kms_key_arn" {
  description = "arn for kms encryption key"
  type        = string
}