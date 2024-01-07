# vnet and subnets
resource "aws_vpc" "vpc_workloads" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.cidr_block_subnet_public)
  vpc_id                  = aws_vpc.vpc_workloads.id
  cidr_block              = element(var.cidr_block_subnet_public, count.index)
  availability_zone       = format("%s%s", var.region, element(var.availability_zones, count.index))
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}_public_${element(var.cidr_block_subnet_public, count.index)}"
  }
}

resource "aws_subnet" "private_subnets" {
  count                   = length(var.cidr_block_subnet_private)
  vpc_id                  = aws_vpc.vpc_workloads.id
  cidr_block              = element(var.cidr_block_subnet_private, count.index)
  availability_zone       = format("%s%s", var.region, element(var.availability_zones, count.index))
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}_private_${element(var.cidr_block_subnet_private, count.index)}"
  }
}

resource "aws_subnet" "database_subnets" {
  count                   = length(var.cidr_block_subnet_database)
  vpc_id                  = aws_vpc.vpc_workloads.id
  cidr_block              = element(var.cidr_block_subnet_database, count.index)
  availability_zone       = format("%s%s", var.region, element(var.availability_zones, count.index))
  map_public_ip_on_launch = false

  tags = {
    Name = "database_10.0.${count.index * 2}.0_${element(var.availability_zones, count.index)}"
  }
}

# public routing rules
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_workloads.id

  tags = {
    Name = "igw_${var.vpc_name}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_workloads.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt_${var.vpc_name}"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.cidr_block_subnet_public)
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

# private routing rules

# resource "aws_eip" "nat_ip" {
#   domain = "vpc"

#   tags = {
#     Name = "eip-nat_${var.vpc_name}"
#   }
# }

// Nat Gateway
# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat_ip.id
#   subnet_id     = element(aws_subnet.public_subnets.*.id, 0)

#   tags = {
#     Name = "nat_${var.vpc_name}"
#   }
# }

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc_workloads.id

  # route {
  #   cidr_block     = "0.0.0.0/0"
  #   nat_gateway_id = aws_nat_gateway.nat.id
  # }

  tags = {
    Name = "private_rt_${var.vpc_name}"
  }
}

resource "aws_route_table" "database_rt" {
  vpc_id = aws_vpc.vpc_workloads.id

  tags = {
    Name = "database_rt_${var.vpc_name}"
  }
}

// Associate private subnets to private route table
resource "aws_route_table_association" "private" {
  count          = length(var.cidr_block_subnet_private)
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "database" {
  count          = length(var.cidr_block_subnet_database)
  subnet_id      = element(aws_subnet.database_subnets.*.id, count.index)
  route_table_id = aws_route_table.database_rt.id
}