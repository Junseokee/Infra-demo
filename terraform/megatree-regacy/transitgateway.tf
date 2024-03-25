resource "aws_ec2_transit_gateway" "tgw" {
  description = "TGW for megatree"
  tags = {
    Name = "megatree-tgw"
  }
}
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attach_1" {
  vpc_id             = aws_vpc.public_vpc.id
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  subnet_ids         = aws_subnet.private_subnet_for_public_vpc[*].id
}
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attach_2" {
  vpc_id             = aws_vpc.private_vpc_1.id
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  subnet_ids = aws_subnet.private_subnet_1[*].id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attach_3" {
  vpc_id             = aws_vpc.private_vpc_2.id
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  subnet_ids = aws_subnet.private_subnet_2[*].id
}

# Transit Gateway 라우팅 테이블 및 연결 설정 (필요한 경우)
