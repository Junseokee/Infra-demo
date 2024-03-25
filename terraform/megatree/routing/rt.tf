resource "aws_route_table" "public_rt" {
  vpc_id = data.terraform_remote_state.project-network-dmz.outputs.public_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.terraform_remote_state.project-network-dmz.outputs.igw_id
#    nat_gateway_id = data.terraform_remote_state.project-network-dmz.outputs.nat_id
  }
  route {
    cidr_block         = data.terraform_remote_state.project-network-app.outputs.vpc_cidr_app
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
    }
  route {
    cidr_block         = data.terraform_remote_state.project-network-share.outputs.vpc_cidr_share
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  tags = {
    Name = "project-public-vpc-rt"
  }
}
resource "aws_route_table" "private_rt_public" {
  vpc_id = data.terraform_remote_state.project-network-dmz.outputs.public_vpc_id

  route {
    cidr_block         = data.terraform_remote_state.project-network-app.outputs.vpc_cidr_app
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  route {
    cidr_block         = data.terraform_remote_state.project-network-share.outputs.vpc_cidr_share
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = data.terraform_remote_state.project-network-dmz.outputs.nat_id
  }
  tags = {
    Name = "project-private-vpc-public-rt"
  }
}


resource "aws_route_table_association" "public_rta" {
  count          = length(data.terraform_remote_state.project-network-dmz.outputs.subnet_dmz_public.*)
  subnet_id      = data.terraform_remote_state.project-network-dmz.outputs.subnet_dmz_public[count.index]
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rta_public" {
  count          = length(data.terraform_remote_state.project-network-dmz.outputs.subnet_dmz_private.*)
  subnet_id      = data.terraform_remote_state.project-network-dmz.outputs.subnet_dmz_private[count.index]
  route_table_id = aws_route_table.private_rt_public.id
}