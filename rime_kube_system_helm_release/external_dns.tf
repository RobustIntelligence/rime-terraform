resource "aws_iam_policy" "eks_dns_policy" {
  count = var.install_external_dns ? 1 : 0

  name = "eks_dns_policy_${var.resource_name_suffix}"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "route53:ChangeResourceRecordSets"
        Effect   = "Allow"
        Resource = ["arn:${data.aws_partition.current.partition}:route53:::hostedzone/*"]
      },
      {
        Action   = ["route53:ListHostedZones", "route53:ListResourceRecordSets"]
        Effect   = "Allow"
        Resource = ["*"]
      },
    ]
  })

  tags = var.tags
}

module "iam_assumable_role_with_oidc_for_route53" {
  count = var.install_external_dns ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 3.0"

  create_role = true

  role_name = "eks_dns_admin_${var.resource_name_suffix}"

  provider_url = var.oidc_provider_url

  role_policy_arns = [
    aws_iam_policy.eks_dns_policy[0].arn,
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSClusterPolicy",
  ]

  number_of_role_policy_arns = 2

  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:rime-kube-system-external-dns"]

  tags = merge({ Role = "eks_dns_admin_${var.resource_name_suffix}" }, var.tags)
}
