data "tfe_organization" "org" {
  name = var.TFC_OGANIZATION_NAME
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