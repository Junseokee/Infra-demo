resource "aws_vpc" "private_vpc_1" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "project-private-vpc-apps"
  }
}
output "vpc_app" {
  value = aws_vpc.private_vpc_1.id
}

output "vpc_cidr_app" {
  value = aws_vpc.private_vpc_1.cidr_block
}
