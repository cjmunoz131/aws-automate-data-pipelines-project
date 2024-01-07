variable "profile_dev" {
  type        = string
  description = "development deployment profile"
  default     = "AdministratorAccess"
}

variable "environment" {
  type        = string
  description = "development environment"
  default     = "development"
}

variable "profile_prod" {
  type        = string
  description = "development production profile"
  default     = "AdministratorAccess"
}

variable "project" {
  type        = string
  description = "Deployment project"
  default     = "reto-pragma"
}

variable "provisioner" {
  type        = string
  description = "Infraestructure provisioner"
  default     = "Terraform"
}

variable "owner" {
  type        = string
  description = "Project Owner"
  default     = "cjmunoz"
}

variable "dev_region" {
  type        = string
  description = "development environment region"
  default     = "us-east-1"
}

variable "prod_region" {
  type        = string
  description = "production environment region"
  default     = "us-east-1"
}

variable "org_unit" {
  type        = string
  description = "Organizational unit"
  default     = "products_crew"
}

variable "fin_unit" {
  type        = string
  description = "finance unit"
  default     = "vice_technology"
}

variable "deployment_profile" {
  type        = string
  description = "deployment profile"
  #  default     = "AWSAdministratorAccess"
  default = "shared-services"
}

variable "deployment_region" {
  type        = string
  description = "deployment region"
  default     = ""
}
########################
variable "key_name" {
  type        = string
  description = "key name value"
  default     = "stedi-default"
}

variable "key_datasource_name" {
  type        = string
  description = "stedi-datasource"
  default     = "stedi-datasource"
}

variable "vpc_name" {
  type        = string
  description = "vpc name"
  default     = "certidemy_vpc"
}

variable "vpc_base_cidr_block" {
  type        = string
  description = "cidr block for vpc"
  default     = "10.0.0.0/16"
}

variable "subnet_public_cidr_blocks" {
  type        = list(string)
  description = "cidr block for vpc"
  default     = ["10.0.0.0/24", "10.0.1.0/24","10.0.6.0/24"]
}

variable "subnet_private_cidr_blocks" {
  type        = list(string)
  description = "cidr block for vpc"
  default     = ["10.0.2.0/24", "10.0.3.0/24","10.0.7.0/24"]
}

variable "subnet_database_cidr_blocks" {
  type        = list(string)
  description = "cidr block for vpc"
  default     = ["10.0.4.0/24", "10.0.5.0/24","10.0.8.0/24"]
}

variable "availability_zones" {
  type        = list(string)
  description = "avalability zones"
  default     = ["a", "b", "c"]
}

variable "region" {
  type        = string
  description = "deployment region"
  default     = "us-east-1"
}

variable "region_shared_services" {
  type        = string
  description = "shared Services region"
  default     = "us-east-1"
}

variable "assests_bucket_name" {
  type        = string
  description = "name for assets bucket"
  default     = "stedi-datasource"
}

variable "shared_services_account" {
  type        = string
  description = "shared services account number"
  default     = ""
}

variable "development_account" {
  type        = string
  description = "development account"
  default     = ""
}

variable "production_account" {
  type        = string
  description = "production account"
  default     = ""
}

variable "datasync_collector_name" {
  type        = string
  description = "datasync collector name"
  default     = "ds-stedi-collector"
}

variable "source_location_s3_subdirectory" {
  type        = string
  description = "subdirectory s3 source location"
  default     = "/sources/"
}

variable "target_location_s3_subdirectory" {
  type        = string
  description = "subdirectory s3 target location"
  default     = "/stedi-datalake/"
}

variable "glue_table_prefix" {
  type        = string
  description = "table prefix for stedi tables in data catalog"
  default     = "stedi_table_"
}

variable "glue_database" {
  type        = string
  description = "glue database name"
  default     = "stedi-database"
}

variable "glue_connection_name" {
  type        = string
  description = "glue connection for job processing and crawler scanning"
  default     = "glue_stedi_connection"
}

variable "datasync_source_location_role" {
  type        = string
  description = "datasync_source_location_role"
  default     = "datasync-s3-source-role"
}

variable "datasync_target_location_role" {
  type        = string
  description = "datasync_target_location_role"
  default     = "datasync-s3-target-role"
}

variable "customer_landing_path" {
  type    = string
  default = "customer/landing/"
}

variable "step_training_landing_path" {
  type    = string
  default = "step_trainer/landing/"
}

variable "accelerometer_landing_path" {
  type    = string
  default = "accelerometer/landing/"
}

variable "landing_crawler_name" {
  type    = string
  default = "stedi-landing-zone-crawler"
}

variable "accelerometer_landing_table_name" {
  type    = string
  default = "accelerometer_landing"
}

variable "customer_landing_table_name" {
  type    = string
  default = "customer_landing"
}

variable "step-trainer_landing_table_name" {
  type    = string
  default = "step_trainer_landing"
}

variable "redshift_sls_publicly_accessible" {
  type    = bool
  default = false
}

variable "reshift_sls_base_capacity" {
  type    = number
  default = 8
}

variable "redshift_sls_database_name" {
  type    = string
  default = "dwh"
}

variable "redshift_sls_wgp_name" {
  type    = string
  default = "dwh-redshift-sls-wgp"
}

variable "redshift_sls_namespace_name" {
  type    = string
  default = "dwh-redshift-sls-ns"
}

variable "redshift_sls_admin_username" {
  type    = string
  default = "dwhadmin"
}

variable "enhanced_vpc_routing_enabled" {
  type    = bool
  default = true
}