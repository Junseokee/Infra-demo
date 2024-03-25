resource "aws_iam_role" "mimir-role" {
  name = "project-role-mimir"
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
            "${replace(aws_eks_cluster.app_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:metric:mimir",
            "${replace(aws_eks_cluster.app_cluster.identity[0].oidc[0].issuer, "https://", "")}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  tags = {
    tag-key = "${local.name}-mimir-iam-role"
  }
}


resource "aws_iam_policy" "mimir-policy" {
  name        = "mimir-policy"
  path        = "/"
  description = "mimir policy"
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
          "arn:aws:s3:::project-mimir",
          "arn:aws:s3:::project-mimir/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "mimir-attach" {
  policy_arn = aws_iam_policy.mimir-policy.arn
  role       = aws_iam_role.mimir-role.name
}

output "mimir_role_arn" {
  value       = aws_iam_role.mimir-role.arn
  description = "mimir ARN of the role"
}