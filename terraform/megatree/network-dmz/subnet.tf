data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Public VPC의 Public 서브넷
resource "aws_subnet" "subnet_dmz_public" {
  count                   = 2
  vpc_id                  = aws_vpc.public_vpc.id
  cidr_block              = slice(["10.1.1.0/24", "10.1.2.0/24"], count.index, count.index + 1)[0]
  availability_zone       = slice(data.aws_availability_zones.available.names, count.index, count.index + 1)[0]
  map_public_ip_on_launch = true # Public 서브넷에서 EC2 인스턴스가 자동으로 퍼블릭 IP를 받도록 설정
  tags = {
    Name = "magatree-public-subnet-${count.index}"
  }
}
output "subnet_dmz_public" {
  value = aws_subnet.subnet_dmz_public[*].id
}

# Public VPC의 Private 서브넷
resource "aws_subnet" "subnet_dmz_private" {
  count             = 2
  vpc_id            = aws_vpc.public_vpc.id
  cidr_block        = slice(["10.1.21.0/24", "10.1.22.0/24"], count.index, count.index + 1)[0]
  availability_zone = slice(data.aws_availability_zones.available.names, count.index, count.index + 1)[0]
  tags = {
    Name = "project-public-subnet-private-${count.index}"
  }
}
output "subnet_dmz_private" {
  value = aws_subnet.subnet_dmz_private[*].id
}