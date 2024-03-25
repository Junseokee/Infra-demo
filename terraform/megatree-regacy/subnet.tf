data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Public VPC의 Public 서브넷
resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.public_vpc.id
  cidr_block              = slice(["10.1.1.0/24", "10.1.2.0/24"], count.index, count.index + 1)[0]
  availability_zone       = slice(data.aws_availability_zones.available.names, count.index, count.index + 1)[0]
  map_public_ip_on_launch = true # Public 서브넷에서 EC2 인스턴스가 자동으로 퍼블릭 IP를 받도록 설정
  tags = {
    Name = "magatree-public-subnet-${count.index}"
  }
}

# Public VPC의 Private 서브넷
resource "aws_subnet" "private_subnet_for_public_vpc" {
  count             = 2
  vpc_id            = aws_vpc.public_vpc.id
  cidr_block        = slice(["10.1.21.0/24", "10.1.22.0/24"], count.index, count.index + 1)[0]
  availability_zone = slice(data.aws_availability_zones.available.names, count.index, count.index + 1)[0]
  tags = {
    Name = "project-public-subnet-private-${count.index}"
  }
}

# Private VPCs의 서브넷
resource "aws_subnet" "private_subnet_1" {
  count             = 2
  vpc_id            = aws_vpc.private_vpc_1.id
  cidr_block        = slice(["10.2.1.0/24", "10.2.2.0/24"], count.index, count.index + 1)[0]
  availability_zone = slice(data.aws_availability_zones.available.names, count.index, count.index + 1)[0]
  tags = {
    Name = "project-private-subnet-apps-${count.index}"
  }
}
resource "aws_subnet" "private_subnet_1_db" {
  count             = 2
  vpc_id            = aws_vpc.private_vpc_1.id
  cidr_block        = slice(["10.2.200.0/24", "10.2.202.0/24"], count.index, count.index + 1)[0]
  availability_zone = slice(data.aws_availability_zones.available.names, count.index, count.index + 1)[0]
  tags = {
    Name = "project-private-subnet-apps-db-${count.index}"
  }
}
resource "aws_subnet" "private_subnet_2" {
  count             = 2
  vpc_id            = aws_vpc.private_vpc_2.id
  cidr_block        = slice(["10.3.1.0/24", "10.3.2.0/24"], count.index, count.index + 1)[0]
  availability_zone = slice(data.aws_availability_zones.available.names, count.index, count.index + 1)[0]
  tags = {
    Name = "project-private-subnet-shared-${count.index}"
  }
}

resource "aws_subnet" "private_subnet_2_db" {
  count             = 2
  vpc_id            = aws_vpc.private_vpc_2.id
  cidr_block        = slice(["10.3.201.0/24", "10.3.202.0/24"], count.index, count.index + 1)[0]
  availability_zone = slice(data.aws_availability_zones.available.names, count.index, count.index + 1)[0]
  tags = {
    Name = "project-private-subnet-shared-db-${count.index}"
  }
}
