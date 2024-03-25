data "tfe_organization" "org" {
  name = var.TFC_OGANIZATION_NAME
}

data "terraform_remote_state" "project-network-dmz" {
  backend = "remote"
  config = {
    organization = data.tfe_organization.org.name
    workspaces = {
      name = var.NETWORK_DMZ_WORKSPACE_NAME
    }
  }
}
output "vpc_id_dmz" {
  value = data.terraform_remote_state.project-network-dmz.outputs.public_vpc_id
}
output "vpc_cidr_dmz" {
  value = data.terraform_remote_state.project-network-dmz.outputs.vpc_cidr_dmz
}
output "subnet_id_dmz_public" {
  value = data.terraform_remote_state.project-network-dmz.outputs.subnet_dmz_public
}

output "subnet_id_dmz_private" {
  value = data.terraform_remote_state.project-network-dmz.outputs.subnet_dmz_private
}
output "igw_id" {
  value = data.terraform_remote_state.project-network-dmz.outputs.igw_id
}
output "nat_id" {
  value = data.terraform_remote_state.project-network-dmz.outputs.nat_id
}


data "terraform_remote_state" "project-network-app" {
  backend = "remote"
  config = {
    organization = data.tfe_organization.org.name
    workspaces = {
      name = var.NETWORK_APP_WORKSPACE_NAME
    }
  }
}
output "vpc_id_app" {
  value = data.terraform_remote_state.project-network-app.outputs.vpc_app
}
output "vpc_cidr_app" {
  value = data.terraform_remote_state.project-network-app.outputs.vpc_cidr_app
}

output "subnet_id_app_subnet" {
  value = data.terraform_remote_state.project-network-app.outputs.subnet_app
}

data "terraform_remote_state" "project-network-share" {
  backend = "remote"
  config = {
    organization = data.tfe_organization.org.name
    workspaces = {
      name = var.NETWORK_SHARE_WORKSPACE_NAME
    }
  }
}
output "vpc_id_share" {
  value = data.terraform_remote_state.project-network-share.outputs.vpc_share
}

output "subnet_id_share_subnet" {
  value = data.terraform_remote_state.project-network-share.outputs.subnet_share_id
}
output "vpc_cidr_share" {
  value = data.terraform_remote_state.project-network-share.outputs.vpc_cidr_share
}