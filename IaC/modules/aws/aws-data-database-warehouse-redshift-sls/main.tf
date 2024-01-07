# Create the Redshift Serverless Namespace
resource "aws_redshiftserverless_namespace" "redshift_serverless_ns" {
  namespace_name      = var.redshift_serverless_namespace_name
  db_name             = var.redshift_serverless_database_name
  admin_username      = var.redshift_serverless_admin_username
  admin_user_password = var.redshift_serverless_admin_password
  iam_roles           = [var.redshift_serverless_iam_role_arn]
  kms_key_id          = var.kms_key_id
  tags = {
    Name = var.redshift_serverless_namespace_name
  }
  lifecycle {
    ignore_changes = [ admin_user_password ]
  }
}

################################################

# Create the Redshift Serverless Workgroup
resource "aws_redshiftserverless_workgroup" "redshift_serverless_wgp" {
  depends_on = [aws_redshiftserverless_namespace.redshift_serverless_ns]

  namespace_name       = aws_redshiftserverless_namespace.redshift_serverless_ns.id
  workgroup_name       = var.redshift_serverless_workgroup_name
  base_capacity        = var.redshift_serverless_base_capacity
  enhanced_vpc_routing = var.enhanced_vpc_routing_enabled
  security_group_ids   = [var.redshift_serverless_sg_id]
  subnet_ids           = var.subnets_id

  publicly_accessible = var.redshift_serverless_publicly_accessible

  tags = {
    Name = var.redshift_serverless_workgroup_name
  }
}