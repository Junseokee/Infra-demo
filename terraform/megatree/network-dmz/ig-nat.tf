resource "aws_internet_gateway" "public_igw" {
  vpc_id = aws_vpc.public_vpc.id
  tags = {
    Name = "project-public-IGW"
  }
}
output "igw_id" {
  value = aws_internet_gateway.public_igw.id
}

resource "aws_eip" "nat_eip" {
  count = 1
}
resource "aws_nat_gateway" "public_nat" {
  count         = 1
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = aws_subnet.subnet_dmz_public[0].id
  tags = {
    Name = "project-NAT"
  }
}
output "nat_id" {
  value = aws_nat_gateway.public_nat[0].id
}