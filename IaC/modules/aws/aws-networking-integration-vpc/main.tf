data "aws_caller_identity" "current" {}

locals {
  gw_endpoints_services = [
    { type = "s3", route_tables = var.vpc_s3_rt_integration }
  ]
  ifc_endpoints_services = [
    # { type = "kms", subnets = var.integration_subnets_assoc, sgs = [aws_security_group.vpcend_sg.id] },
  ]
  datasync_endpoint_service = { type = "datasync", subnets = var.integration_subnets_assoc, sgs = [aws_security_group.vpcend_sg.id] }
}


module "vpc_endpoints_gateway" {
  for_each        = { for gweps in local.gw_endpoints_services : gweps.type => gweps }
  source          = "./aws-vpc-endpoint"
  region          = var.region
  service         = each.key
  route_tables_id = each.value.route_tables
  vpc_main        = var.vpc_workloads_id
  gateway_ep      = true
}

module "vpc_endpoints_interface" {
  for_each           = { for ifeps in local.ifc_endpoints_services : ifeps.type => ifeps }
  source             = "./aws-vpc-endpoint"
  region             = var.region
  service            = each.key
  subnet_ids         = each.value.subnets
  security_group_ids = each.value.sgs
  vpc_main           = var.vpc_workloads_id
  gateway_ep         = false
}

# module "vpc_datasync_endpoint_interface" {
#   source             = "./aws-vpc-endpoint"
#   region             = var.region
#   service            = local.datasync_endpoint_service.type
#   subnet_ids         = local.datasync_endpoint_service.subnets
#   security_group_ids = local.datasync_endpoint_service.sgs
#   vpc_main           = var.vpc_workloads_id
#   gateway_ep         = false
# }

resource "aws_security_group" "vpcend_sg" {
  name        = "vpcend_stedi_sg"
  description = "Allow traffic on port 443 from vpcendpoints services"
  vpc_id      = var.vpc_workloads_id

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    description = "https port"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    description = "all outbound"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpcep_sg"
  }
}