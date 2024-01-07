output "redshift_sls_sg" {
  value = aws_security_group.redshift-serverless-security-group.id
}

output "redshift_sls_role" {
  value = aws_iam_role.redshift-serverless-role.arn
}