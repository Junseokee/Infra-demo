# Private VPCs의 라우팅 테이블
resource "aws_route_table" "private_rt_1" {
  vpc_id = data.terraform_remote_state.project-network-app.outputs.vpc_app

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  route {
    cidr_block         = data.terraform_remote_state.project-network-dmz.outputs.vpc_cidr_dmz
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  route {
    cidr_block         = data.terraform_remote_state.project-network-share.outputs.vpc_cidr_share
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  tags = {
    Name = "project-private-vpc-apps-rt"
  }
}

resource "aws_route_table_association" "private_rta_1" {
  count          = length(data.terraform_remote_state.project-network-app.outputs.subnet_app.*)
  subnet_id      = data.terraform_remote_state.project-network-app.outputs.subnet_app[count.index]
  route_table_id = aws_route_table.private_rt_1.id
}