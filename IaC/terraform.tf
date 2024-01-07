provider "aws" {
  profile = var.deployment_profile
  region  = var.region
  assume_role {
    role_arn = "arn:aws:iam::${lookup(local.account_mapping, local.env)}:role/terraform-role"
  }
  default_tags {
    tags = {
      Customer    = local.commons.customer
      Environment = terraform.workspace
      Org_unit    = local.commons.org_unit
      Provisioner = local.commons.provisioner
      Solution    = local.commons.project
      fin_unit    = local.commons.fin_unit
    }
  }
}

provider "aws" {
  alias   = "shared_provider"
  profile = var.deployment_profile
  region  = var.region_shared_services
  assume_role {
    role_arn = "arn:aws:iam::${local.account_mapping.shared_services}:role/terraform-role"
  }
  default_tags {
    tags = {
      Customer    = local.commons.customer
      Environment = "shared"
      Org_unit    = local.commons.org_unit
      Provisioner = local.commons.provisioner
      Solution    = local.commons.project
      fin_unit    = local.commons.fin_unit
    }
  }
}

terraform {
  required_providers {

    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.10"
    }
  }
}

locals {
  env = terraform.workspace
  account_mapping = {
    default : var.development_account
    dev : var.development_account
    prod : var.production_account
    shared_services : var.shared_services_account
  }
  commons = {
    customer    = var.owner
    org_unit    = var.org_unit
    project     = var.project
    fin_unit    = var.fin_unit
    provisioner = var.provisioner
  }
}

