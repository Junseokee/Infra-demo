resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.public_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_igw.id
    #    nat_gateway_id = aws_nat_gateway.public_nat[0].id
  }
  route {
    cidr_block         = aws_vpc.private_vpc_1.cidr_block
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  route {
    cidr_block         = aws_vpc.private_vpc_2.cidr_block
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  tags = {
    Name = "project-public-vpc-rt"
  }
}
resource "aws_route_table" "private_rt_public" {
  vpc_id = aws_vpc.public_vpc.id

  route {
    cidr_block         = aws_vpc.private_vpc_1.cidr_block
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  route {
    cidr_block         = aws_vpc.private_vpc_2.cidr_block
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public_nat[0].id
  }
  tags = {
    Name = "project-private-vpc-public-rt"
  }
}

# Private VPCs의 라우팅 테이블
resource "aws_route_table" "private_rt_1" {
  vpc_id = aws_vpc.private_vpc_1.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  route {
    cidr_block         = aws_vpc.public_vpc.cidr_block
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  route {
    cidr_block         = aws_vpc.private_vpc_2.cidr_block
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  tags = {
    Name = "project-private-vpc-apps-rt"
  }
}

resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.private_vpc_2.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  route {
    cidr_block         = aws_vpc.public_vpc.cidr_block
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  route {
    cidr_block         = aws_vpc.private_vpc_1.cidr_block
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  tags = {
    Name = "project-private-vpc-shared-rt"
  }
}

# 라우팅 테이블과 서브넷 연결
resource "aws_route_table_association" "public_rta" {
  count          = length(aws_subnet.public_subnet.*.id)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rta_public" {
  count          = length(aws_subnet.private_subnet_for_public_vpc.*.id)
  subnet_id      = aws_subnet.private_subnet_for_public_vpc[count.index].id
  route_table_id = aws_route_table.private_rt_public.id
}

resource "aws_route_table_association" "private_rta_1" {
  count          = length(aws_subnet.private_subnet_1.*.id)
  subnet_id      = aws_subnet.private_subnet_1[count.index].id
  route_table_id = aws_route_table.private_rt_1.id
}

resource "aws_route_table_association" "private_rta_2" {
  count          = length(aws_subnet.private_subnet_2.*.id)
  subnet_id      = aws_subnet.private_subnet_2[count.index].id
  route_table_id = aws_route_table.private_rt_2.id
}


###################################################
## NAT Gateway
#resource "aws_route_table" "route_table_nat" {
#  vpc_id = aws_vpc.public_vpc.id
#}
#
#resource "aws_route_table_association" "route_table_nat_association" {
#  count          = length(aws_subnet.private_subnet_for_public_vpc.*.id)
#  subnet_id      = aws_subnet.private_subnet_for_public_vpc[count.index].id
#  route_table_id = aws_route_table.route_table_nat.id
#}
#
#resource "aws_route" "route_nat" {
#  count                  = length(aws_subnet.private_subnet_for_public_vpc.*.id)
#  route_table_id         = aws_route_table.route_table_nat.id
#  destination_cidr_block = "0.0.0.0/0"
#  nat_gateway_id         = aws_nat_gateway.public_nat[0].id
#}