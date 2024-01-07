# output "datasync_vpc_ept_id" {
#   value = (module.vpc_endpoints_interface)[1].vpc_endpoints_interface_id
# }

# output "datasync_vpc_ept_id" {
#   value = module.vpc_datasync_endpoint_interface.vpc_endpoints_interface_id
# }

output "vpc_s3_endpoint_sg" {
  value = aws_security_group.vpcend_sg.id
}