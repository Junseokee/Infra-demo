resource "aws_s3_bucket" "project-loki" {
  bucket = "${local.name}-loki"
  tags = {
    Name = "${local.name}-loki"
  }
}

resource "aws_s3_bucket" "project-mimir" {
  bucket = "${local.name}-mimir"
  tags = {
    Name = "${local.name}-mimir"
  }
}

resource "aws_s3_bucket" "project-tempo" {
  bucket = "${local.name}-tempo"
  tags = {
    Name = "${local.name}-tempo"
  }
}