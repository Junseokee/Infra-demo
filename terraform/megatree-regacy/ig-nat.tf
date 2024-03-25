resource "aws_internet_gateway" "public_igw" {
  vpc_id = aws_vpc.public_vpc.id
  tags = {
    Name = "project-public-IGW"
  }
}

resource "aws_eip" "nat_eip" {
  count = 1
}

resource "aws_nat_gateway" "public_nat" {
  count         = 1
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = aws_subnet.public_subnet[0].id
  tags = {
    Name = "project-NAT"
  }
}
