data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}


resource "aws_subnet" "subnet_share" {
  count             = 2
  vpc_id            = aws_vpc.private_vpc_2.id
  cidr_block        = slice(["10.3.1.0/24", "10.3.2.0/24"], count.index, count.index + 1)[0]
  availability_zone = slice(data.aws_availability_zones.available.names, count.index, count.index + 1)[0]
  tags = {
    Name = "project-private-subnet-shared-${count.index}"
  }
}
output "subnet_share_id" {
  value = aws_subnet.subnet_share[*].id
}

resource "aws_subnet" "subnet_share_db" {
  count             = 2
  vpc_id            = aws_vpc.private_vpc_2.id
  cidr_block        = slice(["10.3.201.0/24", "10.3.202.0/24"], count.index, count.index + 1)[0]
  availability_zone = slice(data.aws_availability_zones.available.names, count.index, count.index + 1)[0]
  tags = {
    Name = "project-private-subnet-shared-db-${count.index}"
  }
}
output "subnet_share_db_id" {
  value = aws_subnet.subnet_share_db[*].id
}
