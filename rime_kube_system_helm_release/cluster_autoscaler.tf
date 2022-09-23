resource "aws_iam_policy" "eks_cluster_autoscaler_policy" {
  count = var.install_cluster_autoscaler ? 1 : 0

  name = "eks_cluster_autoscaler_policy_${var.resource_name_suffix}"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action : [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
    ]
  })

  tags = var.tags
}

module "iam_assumable_role_with_oidc_for_autoscaler" {
  count   = var.install_cluster_autoscaler ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 3.0"

  create_role = true

  role_name = "eks_cluster_autoscaler_${var.resource_name_suffix}"

  provider_url = var.oidc_provider_url

  role_policy_arns = [
    aws_iam_policy.eks_cluster_autoscaler_policy[0].arn,
  ]

  number_of_role_policy_arns = 1

  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:rime-kube-system-aws-cluster-autoscaler"]

  tags = merge({ Role = "eks_cluster_autoscaler_policy_${var.resource_name_suffix}" }, var.tags)
}
