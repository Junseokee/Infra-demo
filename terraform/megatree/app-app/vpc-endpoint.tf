resource "aws_vpc_endpoint" "s3-endpoint" {
  vpc_id       = data.terraform_remote_state.project-network-app.outputs.vpc_app
  service_name = "com.amazonaws.${var.REGION}.s3"
  vpc_endpoint_type = "Gateway"
}
