data "tfe_organization" "org" {
  name = var.TFC_OGANIZATION_NAME
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
output "subnet_share_db_id" {
  value = data.terraform_remote_state.project-network-share.outputs.subnet_share_db_id
}

data "terraform_remote_state" "project-app-app" {
  backend = "remote"
  config = {
    organization = data.tfe_organization.org.name
    workspaces   = {
      name = var.APP_APP_WORKSPACE_NAME
    }
  }
}

output "alb_role_arn" {
  value = data.terraform_remote_state.project-app-app.outputs.alb_role_arn
}

output "eks_master_role" {
  value = data.terraform_remote_state.project-app-app.outputs.eks_master_role
}

output "eks_nodegroup_role" {
  value = data.terraform_remote_state.project-app-app.outputs.eks_nodegroup_role
}