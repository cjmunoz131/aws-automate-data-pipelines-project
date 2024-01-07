output "mwaa_webserver_url" {
  description = "The webserver URL of the MWAA Environment"
  value       = aws_mwaa_environment.mwaa.webserver_url
}

output "mwaa_arn" {
  description = "The ARN of the MWAA Environment"
  value       = aws_mwaa_environment.mwaa.arn
}

output "mwaa_service_role_arn" {
  description = "The Service Role ARN of the Amazon MWAA Environment"
  value       = aws_mwaa_environment.mwaa.service_role_arn
}

output "mwaa_status" {
  description = "The status of the Amazon MWAA Environment"
  value       = aws_mwaa_environment.mwaa.status
}
