variable "vpc_main" {
  type        = string
  description = "vpc where endpoints will be created"
}

variable "service" {
  type        = string
  description = "service type that will be using the endpoint"
}

variable "region" {
  type        = string
  description = "region where is deployed the endpoint and service"
}

variable "gateway_ep" {
  type        = bool
  description = "is a gateway endpoint"
}

variable "route_tables_id" {
  type        = set(string)
  description = "list of route tables id"
  default     = null
  nullable    = true
}

variable "security_group_ids" {
  type        = set(string)
  description = "security groups ids"
  default     = null
  nullable    = true
}

variable "subnet_ids" {
  type        = set(string)
  description = "subnet ids"
  default     = null
  nullable    = true
}