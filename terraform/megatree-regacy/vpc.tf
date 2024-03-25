resource "aws_vpc" "public_vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "megatree-public-vpc"
  }
}
output "public_vpc_id" {
  value = aws_vpc.public_vpc.id
}

resource "aws_vpc" "private_vpc_1" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "megatree-private-vpc-apps"
  }
}
output "private_vpc_1_id" {
  value = aws_vpc.private_vpc_1.id
}

resource "aws_vpc" "private_vpc_2" {
  cidr_block           = "10.3.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "megatree-private-vpc-shared"
  }
}
output "private_vpc_2_id" {
  value = aws_vpc.private_vpc_2.id
}