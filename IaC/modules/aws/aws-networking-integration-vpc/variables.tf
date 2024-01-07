variable "vpc_workloads_id" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_s3_rt_integration" {
  type = set(string)
}

variable "integration_subnets_assoc" {
  type = set(string)
}