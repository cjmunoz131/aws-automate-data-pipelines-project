resource "aws_vpc_endpoint" "vpcend-gateway" {
  count             = var.gateway_ep ? 1 : 0
  vpc_id            = var.vpc_main
  service_name      = "com.amazonaws.${var.region}.${var.service}"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_tables_id

  tags = {
    Name = "vpcend-${var.service}"
  }
}


resource "aws_vpc_endpoint" "vpcend-interface" {
  count               = var.gateway_ep ? 0 : 1
  vpc_id              = var.vpc_main
  service_name        = "com.amazonaws.${var.region}.${var.service}"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = var.security_group_ids
  subnet_ids          = var.subnet_ids
  ip_address_type     = "ipv4"
  private_dns_enabled = true

  tags = {
    Name = "vpcend-${var.service}"
  }
}