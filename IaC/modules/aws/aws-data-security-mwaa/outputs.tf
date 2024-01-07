output "mwaa_role_arn" {
  description = "IAM Role ARN of the MWAA Environment"
  value       = aws_iam_role.mwaa_role.arn
}

output "mwaa_role_id" {
  description = "IAM role name of the MWAA Environment"
  value       = aws_iam_role.mwaa_role.id
}

output "mwaa_security_group_id" {
  description = "Security group id of the MWAA Environment"
  value       = aws_security_group.mwaa_sg
}