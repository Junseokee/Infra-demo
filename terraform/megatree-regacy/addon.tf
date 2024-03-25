############################################
# APP Cluster EKS
############################################
resource "aws_eks_addon" "app_cluster_vpc-cni" {
  cluster_name                = aws_eks_cluster.app_cluster.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  addon_version               = "v1.15.1-eksbuild.1"
  tags = {
    "eks_addon" = "aws-vpc-cni"
  }
}

resource "aws_eks_addon" "app_cluster_kube-proxy" {
  cluster_name                = aws_eks_cluster.app_cluster.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  addon_version               = "v1.28.2-eksbuild.2"
  depends_on = [
    aws_eks_cluster.share_cluster,
    aws_eks_node_group.cd_nodes,
    aws_eks_node_group.app_nodes
  ]
  tags = {
    "eks_addon" = "aws-kube-proxy"
  }
}

############################################
# APP Cluster EKS
############################################
resource "aws_eks_addon" "share_cluster_vpc-cni" {
  cluster_name                = aws_eks_cluster.share_cluster.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  addon_version               = "v1.15.1-eksbuild.1"
  tags = {
    "eks_addon" = "aws-vpc-cni"
  }
  depends_on = [
    aws_eks_cluster.share_cluster,
    aws_eks_node_group.ci_nodes
  ]
}

resource "aws_eks_addon" "share_cluster_kube-proxy" {
  cluster_name                = aws_eks_cluster.share_cluster.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  addon_version               = "v1.28.2-eksbuild.2"
  tags = {
    "eks_addon" = "aws-kube-proxy"
  }
}