resource "aws_iam_role" "tempo-role" {
  name = "project-role-tempo"
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
            "${replace(aws_eks_cluster.app_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:trace:tempo",
            "${replace(aws_eks_cluster.app_cluster.identity[0].oidc[0].issuer, "https://", "")}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  tags = {
    tag-key = "${local.name}-tempo-iam-role"
  }
}

resource "aws_iam_policy" "tempo-policy" {
  name        = "tempo-policy"
  path        = "/"
  description = "tempo policy"
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
          "arn:aws:s3:::project-tempo",
          "arn:aws:s3:::project-tempo/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "tempo-attach" {
  policy_arn = aws_iam_policy.tempo-policy.arn
  role       = aws_iam_role.tempo-role.name
}

output "tempo_role_arn" {
  value       = aws_iam_role.tempo-role.arn
  description = "tempo ARN of the role"
}