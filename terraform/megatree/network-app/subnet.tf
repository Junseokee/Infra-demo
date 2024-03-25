data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Private VPCs의 서브넷
resource "aws_subnet" "subnet_app" {
  count             = 2
  vpc_id            = aws_vpc.private_vpc_1.id
  cidr_block        = slice(["10.2.1.0/24", "10.2.2.0/24"], count.index, count.index + 1)[0]
  availability_zone = slice(data.aws_availability_zones.available.names, count.index, count.index + 1)[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "project-private-subnet-apps-${count.index}"
  }
}
output "subnet_app" {
  value = aws_subnet.subnet_app[*].id
}

resource "aws_subnet" "subnet_app_db" {
  count             = 2
  vpc_id            = aws_vpc.private_vpc_1.id
  cidr_block        = slice(["10.2.200.0/24", "10.2.202.0/24"], count.index, count.index + 1)[0]
  availability_zone = slice(data.aws_availability_zones.available.names, count.index, count.index + 1)[0]
  tags = {
    Name = "project-private-subnet-apps-db-${count.index}"
  }
}
output "subnet_app_db" {
  value = aws_subnet.subnet_app_db[*].id
}