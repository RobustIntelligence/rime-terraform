# Provisions an EKS cluster for RIME to be deployed onto.
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  // TODO(blaine): We have to peg our module because version 18.0.0 removed many inputs;
  // investigate how to migrate to 18.0.0 so that we're not using old modules.
  version = "17.24.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnets         = var.private_subnet_ids

  tags = var.tags

  # Enable IAM roles for service accounts so we can assign IAM roles to
  # k8s service accounts for fine-grained access control. This is required for RIME to function.
  enable_irsa = true


  vpc_id = var.vpc_id

  #cluster autoscaler will take care of changing desired capacity as needed
  worker_groups_launch_template = [
    merge({
      name                 = "rime-worker-group"
      instance_type        = "t2.xlarge"
      asg_min_size         = var.server_worker_group_min_size
      asg_desired_capacity = 4
      asg_max_size         = var.server_worker_group_max_size
      tags = [
        {
          key                 = "k8s.io/cluster-autoscaler/enabled"
          value               = "TRUE",
          propagate_at_launch = true
        },
        {
          key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          value               = "owned",
          propagate_at_launch = true
        }
      ]
    }, var.server_worker_groups_overrides),
    merge({
      name                 = "rime-worker-group-model-testing"
      instance_type        = var.model_testing_worker_group_instance_types[0]
      override_instance_types = slice(var.model_testing_worker_group_instance_types, 1, length(var.model_testing_worker_group_instance_types))
      asg_min_size         = var.model_testing_worker_group_min_size
      asg_desired_capacity = var.model_testing_worker_group_min_size
      asg_max_size         = var.model_testing_worker_group_max_size
      # Mixed Instance Policy Configurations. May need to tune. Currently we either use all spot or all on-demand.
      # Mixed Instance Policy docs: https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_MixedInstancesPolicy.html
      on_demand_base_capacity = "0"
      on_demand_percentage_above_base_capacity = var.model_testing_worker_group_use_spot ? "0" : "100"
      spot_allocation_strategy = "lowest-price"
      kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=${var.model_testing_worker_group_use_spot ? "spot" : "normal"},dedicated=model-testing --register-with-taints=dedicated=model-testing:NoSchedule"

      tags = [
        {
          key                 = "k8s.io/cluster-autoscaler/enabled"
          value               = "TRUE",
          propagate_at_launch = true
        },
        {
          key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          value               = "owned",
          propagate_at_launch = true
        },
        {
          key                 = "k8s.io/cluster-autoscaler/node-template/label/dedicated"
          value               = "model-testing",
          propagate_at_launch = true
        }
      ]
    }, var.model_testing_worker_groups_overrides)
  ]
  workers_additional_policies = var.allow_ecr_pull ? concat(var.eks_cluster_node_iam_policies, [aws_iam_policy.node_ecr_policy[0].arn]) : var.eks_cluster_node_iam_policies

  map_roles        = var.map_roles
  map_users        = var.map_users
  write_kubeconfig = false
}

#Permissions based off this guide: https://docs.aws.amazon.com/AmazonECR/latest/userguide/ECR_on_EKS.html
resource "aws_iam_policy" "node_ecr_policy" {
  count = var.allow_ecr_pull ? 1 : 0

  name = "eks_node_ecr_policy_${var.cluster_name}"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action : [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken"
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
    ]
  })

  tags = var.tags
}

resource "aws_ec2_tag" "vpc_tags" {
  resource_id = var.vpc_id
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

resource "aws_ec2_tag" "private_subnet_cluster_tag" {
  for_each = toset(var.private_subnet_ids)

  resource_id = each.key
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

resource "aws_ec2_tag" "private_subnet_elb_tag" {
  for_each = toset(var.private_subnet_ids)

  resource_id = each.key
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}


resource "aws_ec2_tag" "public_subnet_cluster_tag" {
  for_each = toset(var.public_subnet_ids)

  resource_id = each.key
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "public_subnet_elb_tag" {
  for_each = toset(var.public_subnet_ids)

  resource_id = each.key
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

#Storage class that allows expansion in case we need to resize db later. Used in mongo and redis helm chart
resource "kubernetes_storage_class" "expandable_storage" {
  metadata {
    name = var.expandable_storage_class_name
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Delete"
  parameters = {
    type      = "gp2"
    fstype    = "ext4"
    encrypted = "true"
  }
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"
}

module "iam_assumable_role_with_oidc_for_ebs_controller" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 3.0"

  create_role = true

  role_name        = "rime_ebs_${var.cluster_name}" # must be <= 64
  role_description = "Role to provision block storage for rime cluster."

  provider_url = replace(module.eks.cluster_oidc_issuer_url, "https://", "")

  role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ]

  number_of_role_policy_arns = 1

  oidc_fully_qualified_subjects = [
    "system:serviceaccount:kube-system:ebs-csi-controller-sa",
  ]

  tags = var.tags
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name = module.eks.cluster_id
  addon_name   = "aws-ebs-csi-driver"
  service_account_role_arn = module.iam_assumable_role_with_oidc_for_ebs_controller.this_iam_role_arn
}
