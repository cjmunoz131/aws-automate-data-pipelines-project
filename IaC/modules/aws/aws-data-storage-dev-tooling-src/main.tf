module "aws_storage_dev_tooling_s3_module" {
  source                      = "../aws-storage-basic-bucket-s3"
  kms_key_arn                 = var.kms_key_arn
  bucket_name                 = var.dev_tooling_bucket_name
  cross_target_accounts_roles = []
}

#upload all dev tooling
resource "aws_s3_object" "objects" {
  bucket = module.aws_storage_dev_tooling_s3_module.bucket_name

  for_each   = fileset("../${path.root}/data_dev/src/", "**/*.*")
  key        = "${var.source_location_s3_subdirectory}/${each.value}"
  source     = "../${path.root}/data_dev/src/${each.value}"
  kms_key_id = var.kms_key_arn
  depends_on = [
    module.aws_storage_dev_tooling_s3_module
  ]
}