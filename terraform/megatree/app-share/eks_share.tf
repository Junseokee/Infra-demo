locals {
  name = "project"
}

#####################
# EKS Cluster
#####################
resource "aws_eks_cluster" "share_cluster" {
  name     = "${local.name}-share-cluster"
  role_arn = data.terraform_remote_state.project-app-app.outputs.eks_master_role
  version  = "1.28"
  vpc_config {
    subnet_ids              = data.terraform_remote_state.project-network-share.outputs.subnet_share_id[*]
    endpoint_public_access  = true
    endpoint_private_access = true
    public_access_cidrs = [
      "0.0.0.0/0"
    ]
  }
  tags = {
    Name = "${local.name}-share-cluster"
  }
}


#####################
# EKS Node Group
#####################

resource "aws_eks_node_group" "ci_nodes" {
  cluster_name    = aws_eks_cluster.share_cluster.name
  node_group_name = "${aws_eks_cluster.share_cluster.name}-ci-nodegroup"
  node_role_arn   = data.terraform_remote_state.project-app-app.outputs.eks_nodegroup_role
  subnet_ids      = data.terraform_remote_state.project-network-share.outputs.subnet_share_id[*]
  update_config {
    max_unavailable = 1
  }
  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }
  instance_types = ["c5.2xlarge"]
  capacity_type  = "ON_DEMAND"
  disk_size      = 20

  tags = {
    Name = "${aws_eks_cluster.share_cluster.name}-ci-nodegroup"
  }
}