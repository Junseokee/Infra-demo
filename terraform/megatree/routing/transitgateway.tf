resource "aws_ec2_transit_gateway" "tgw" {
  description = "TGW for project"
  tags = {
    Name = "project-tgw"
  }
}
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attach_1" {
  vpc_id             = data.terraform_remote_state.project-network-dmz.outputs.public_vpc_id
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  subnet_ids         = data.terraform_remote_state.project-network-dmz.outputs.subnet_dmz_private[*]
  tags = {
    Name = "project-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attach_2" {
  vpc_id             = data.terraform_remote_state.project-network-app.outputs.vpc_app
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  subnet_ids = data.terraform_remote_state.project-network-app.outputs.subnet_app[*]
  tags = {
    Name = "project-tgw"
  }
}


resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attach_3" {
  vpc_id             = data.terraform_remote_state.project-network-share.outputs.vpc_share
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  subnet_ids = data.terraform_remote_state.project-network-share.outputs.subnet_share_id[*]
  tags = {
    Name = "project-tgw"
  }
}

resource "aws_ec2_transit_gateway_route" "tgw_igw" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tgw.association_default_route_table_id
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw_attach_1.id
}