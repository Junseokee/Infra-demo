resource "aws_route_table" "private_rt_2" {
  vpc_id = data.terraform_remote_state.project-network-share.outputs.vpc_share

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  route {
    cidr_block         = data.terraform_remote_state.project-network-dmz.outputs.vpc_cidr_dmz
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  route {
    cidr_block         = data.terraform_remote_state.project-network-app.outputs.vpc_cidr_app
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  tags = {
    Name = "project-private-vpc-shared-rt"
  }
}


resource "aws_route_table_association" "private_rta_2" {
  count          = length(data.terraform_remote_state.project-network-share.outputs.subnet_share_id.*)
  subnet_id      = data.terraform_remote_state.project-network-share.outputs.subnet_share_id[count.index]
  route_table_id = aws_route_table.private_rt_2.id
}