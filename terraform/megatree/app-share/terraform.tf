terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7.0"
    }
    http = {
      source = "hashicorp/http"
      #version = "2.1.0"
      #version = "~> 2.1"
      version = "~> 3.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }
  }
}

provider "aws" {
  region = var.REGION
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

provider "http" {
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.share_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.share_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.share_cluster.token
#    load_config_file       = false
  }
}