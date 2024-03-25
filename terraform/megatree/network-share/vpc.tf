resource "aws_vpc" "private_vpc_2" {
  cidr_block           = "10.3.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "project-private-vpc-shared"
  }
}
output "vpc_share" {
  value = aws_vpc.private_vpc_2.id
}

output "vpc_cidr_share" {
  value = aws_vpc.private_vpc_2.cidr_block
}
