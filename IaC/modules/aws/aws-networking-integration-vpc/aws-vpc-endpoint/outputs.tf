# output "vpc_endpoints_interface_id" {
#   value = aws_vpc_endpoint.vpcend-interface.id
# }

# output "vpc_endpoints_interface_ip" {
#   value = (tolist(aws_vpc_endpoint.vpcend-interface.network_interface_ids)[0]).private_ip
# }