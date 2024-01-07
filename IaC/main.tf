data "aws_caller_identity" "current" {}

resource "random_password" "header_cf_apigateway" {
  length = 20
}

module "aws_security_keys_kms_layer_module" {
  source   = "./modules/aws/aws-security-keys-kms"
  key_name = var.key_name
}

# module "aws_security_keys_kms_datasource_layer_module" {
#   providers = {
#     aws = aws.shared_provider
#   }
#   source   = "./modules/aws/aws-security-keys-kms"
#   key_name = var.key_datasource_name
# }

# module "aws_security_keys_kms_iam_datasource_layer_module" {
#   providers = {
#     aws = aws.shared_provider
#   }
#   source = "./modules/aws/aws-security-keys-kms-iam"
#   cross_target_accounts_roles = [{
#     account   = var.development_account,
#     role_name = var.datasync_source_location_role
#   }]
#   kms_key_id = module.aws_security_keys_kms_datasource_layer_module.kms_key_id
# }

module "aws_security_keys_kms_iam_layer_module" {
  source     = "./modules/aws/aws-security-keys-kms-iam"
  kms_key_id = module.aws_security_keys_kms_layer_module.kms_key_id
}

module "aws_data_storage_datalake_s3_layer_module" {
  source      = "./modules/aws/aws-data-storage-datalake-s3"
  kms_key_arn = module.aws_security_keys_kms_layer_module.kms_key_arn
}

# module "aws_storage_datasource_s3_layer_module" {
#   providers = {
#     aws = aws.shared_provider
#   }
#   source                          = "./modules/aws/aws-storage-datasource-s3"
#   kms_key_arn                     = module.aws_security_keys_kms_datasource_layer_module.kms_key_arn
#   bucket_assests_name             = var.assests_bucket_name
#   datasync-s3-source-role         = var.datasync_source_location_role
#   source_location_s3_subdirectory = var.source_location_s3_subdirectory
#   cross_target_accounts_roles = [{
#     account   = var.development_account,
#     role_name = var.datasync_source_location_role
#     },
#     {
#       account   = var.development_account,
#       role_name = "terraform-role"
#   }]
# }

module "aws_networking_base_vpc_layer_module" {
  source                     = "./modules/aws/aws-networking-base-vpc"
  cidr_block                 = var.vpc_base_cidr_block
  cidr_block_subnet_public   = var.subnet_public_cidr_blocks
  cidr_block_subnet_private  = var.subnet_private_cidr_blocks
  cidr_block_subnet_database = var.subnet_database_cidr_blocks
  availability_zones         = var.availability_zones
  region                     = var.region
  vpc_name                   = var.vpc_name
}

module "aws_networking_integration_vpc_layer_module" {
  source                    = "./modules/aws/aws-networking-integration-vpc"
  vpc_workloads_id          = module.aws_networking_base_vpc_layer_module.vpc_workloads_id
  region                    = var.region
  vpc_s3_rt_integration     = [module.aws_networking_base_vpc_layer_module.private_route_table_id]
  integration_subnets_assoc = module.aws_networking_base_vpc_layer_module.subnet_database_ids
}

# module "aws_data_collection_datasync_layer_module" {
#   source                                   = "./modules/aws/aws-data-collection-datasync"
#   s3_datasource_arn                        = module.aws_storage_datasource_s3_layer_module.blob_media_bucket_s3_arn
#   s3_datalake_arn                          = module.aws_data_storage_datalake_s3_layer_module.s3_bucket_arn
#   kms_key_arn                              = module.aws_security_keys_kms_layer_module.kms_key_arn
#   kms_key_source_arn                       = module.aws_security_keys_kms_datasource_layer_module.kms_key_arn
#   datasync_collector_name                  = var.datasync_collector_name
#   datasync_source_location_s3_subdirectory = var.source_location_s3_subdirectory
#   datasync_target_location_s3_subdirectory = var.target_location_s3_subdirectory
#   datasync_source_location_role            = var.datasync_source_location_role
#   datasync_target_location_role            = var.datasync_target_location_role
# }

module "aws_data_security_warehouse_redshift_sls_layer_module" {
  source             = "./modules/aws/aws-data-security-warehouse-redshift-sls"
  s3_bucket_arn      = module.aws_data_storage_datalake_s3_layer_module.s3_bucket_arn
  kms_key_arn        = module.aws_security_keys_kms_layer_module.kms_key_arn
  vpc_id             = module.aws_networking_base_vpc_layer_module.vpc_workloads_id
  glue_database_name = var.glue_database
  glue_table_prefix  = var.glue_table_prefix
}

module "aws_data_database_warehouse_redshift_sls_layer_module" {
  source                                  = "./modules/aws/aws-data-database-warehouse-redshift-sls"
  redshift_serverless_namespace_name      = var.redshift_sls_namespace_name
  redshift_serverless_publicly_accessible = var.redshift_sls_publicly_accessible
  redshift_serverless_database_name       = var.redshift_sls_database_name
  redshift_serverless_admin_username      = var.redshift_sls_admin_username
  redshift_serverless_admin_password      = random_password.header_cf_apigateway.result
  redshift_serverless_base_capacity       = var.reshift_sls_base_capacity
  redshift_serverless_workgroup_name      = var.redshift_sls_wgp_name
  redshift_serverless_sg_id               = module.aws_data_security_warehouse_redshift_sls_layer_module.redshift_sls_sg
  subnets_id                              = module.aws_networking_base_vpc_layer_module.subnet_public_ids
  #subnets_id = module.aws_networking_base_vpc_layer_module.subnet_database_ids
  redshift_serverless_iam_role_arn = module.aws_data_security_warehouse_redshift_sls_layer_module.redshift_sls_role
  kms_key_id                       = module.aws_security_keys_kms_layer_module.kms_key_arn
  enhanced_vpc_routing_enabled     = var.enhanced_vpc_routing_enabled
}