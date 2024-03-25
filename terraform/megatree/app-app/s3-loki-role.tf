resource "aws_iam_role" "loki-role" {
  name = "project-role-loki"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.app_cluster.identity[0].oidc[0].issuer, "https://", "")}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${replace(aws_eks_cluster.app_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:log:loki",
            "${replace(aws_eks_cluster.app_cluster.identity[0].oidc[0].issuer, "https://", "")}:aud" : "sts.amazonaws.com"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.app_cluster.identity[0].oidc[0].issuer, "https://", "")}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${replace(aws_eks_cluster.app_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:log:loki-compactor",
            "${replace(aws_eks_cluster.app_cluster.identity[0].oidc[0].issuer, "https://", "")}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  tags = {
    tag-key = "${local.name}-loki-iam-role"
  }
}

resource "aws_iam_policy" "loki-policy" {
  name        = "loki-policy"
  path        = "/"
  description = "loki policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::project-loki",
          "arn:aws:s3:::project-loki/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "loki-attach" {
  policy_arn = aws_iam_policy.loki-policy.arn
  role       = aws_iam_role.loki-role.name
}

output "loki_role_arn" {
  value       = aws_iam_role.loki-role.arn
  description = "Loki ARN of the role"
}

