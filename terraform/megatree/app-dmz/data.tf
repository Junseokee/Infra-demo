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
output "subnet_id_dmz_public" {
  value = data.terraform_remote_state.project-network-dmz.outputs.subnet_dmz_public
}

output "subnet_dmz_private" {
  value = data.terraform_remote_state.project-network-dmz.outputs.subnet_dmz_private
}