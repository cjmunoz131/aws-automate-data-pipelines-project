variable "cidr_block" {
  type = string
}

variable "cidr_block_subnet_public" {
  type = list(string)

}

variable "cidr_block_subnet_private" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "cidr_block_subnet_database" {
  type = list(string)
}

variable "vpc_name" {
  type = string
}

variable "region" {
  type = string
}