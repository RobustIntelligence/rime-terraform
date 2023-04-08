# rime
The `rime` Terraform module creates all necessary resources for a RIME K8s
cluster on AWS. It builds upon the previous `rime` Terraform module by adding
support for multi-tenancy.

The module is broken down into **five** sub-modules:
- [`rime_eks_cluster`](#rime-eks-cluster): The underlying EKS cluster and its
  associated resources.
- [`rime_kube_system_helm_release`](#rime-kube-system-helm-release):
  Select K8s services for managing infrastructure.
- [`rime_extras_helm_release`](#rime-extras-helm-release): Add-on services for
  backups and observability.
- [`rime_helm_release`](#rime-helm-release): For deploying the core `rime`
  Helm chart and its necessary resources.
- [`rime_agent`](#rime-agent): For deploying the `rime-agent` Helm chart and
  its necessary resources.
- [`route53`](#route53): Optional DNS configuration using route53 (must have
  a hosted zone configured beforehand).

### `rime_eks_cluster`
Provisions an EKS cluster in the specified VPC and subnets, with
[IRSA](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
enabled. Compute resources can be [Managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) or [Self-managed nodes](https://docs.aws.amazon.com/eks/latest/userguide/worker.html).

For more information on the `eks` Terraform module, please see the [module
 documentation](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/17.24.0).

### `rime_kube_system_helm_release`
Provisions the following K8s services for managing infrastructure:
- [Kubernetes Cluster Autoscaler](https://docs.aws.amazon.com/eks/latest/userguide/autoscaling.html)
- [External DNS](https://github.com/kubernetes-sigs/external-dns)
- [Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)
- [Metrics Server](https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html)

These services are optional; however, they are strongly recommended. Robust
Intelligence cannot guarantee the same SLAs when omitting or replacing these
services.

### `rime_extras_helm_release`
Creates a Helm release to provision the following K8s services for additional
functionality:
- [Datadog Agent](https://docs.datadoghq.com/agent/) (monitoring)
- [Velero](https://velero.io/) (disaster recovery)

These services are optional; however they are strongly recommended to
optimize product experience.

### `rime_helm_release`
Creates a Helm release for the control plane.

Your Robust Intelligence representative will help you determine what
configurations to use.

### `rime_agent`
Creates a Helm release for the data plane agent.

Your Robust Intelligence representative will help you determine what
configurations to use.

### `route53` (optional)
Optional module to automatically add DNS entry(ies) to an existing hosted zone.
Must have a valid certificate in ACM to use.
