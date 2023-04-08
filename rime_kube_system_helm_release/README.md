<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | > 0.14, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.75.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | > 2.1.0, < 3.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0.1, < 3.0.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.62.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.9.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.19.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_assumable_role_with_oidc_for_autoscaler"></a> [iam\_assumable\_role\_with\_oidc\_for\_autoscaler](#module\_iam\_assumable\_role\_with\_oidc\_for\_autoscaler) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | ~> 3.0 |
| <a name="module_iam_assumable_role_with_oidc_for_load_balancer_controller"></a> [iam\_assumable\_role\_with\_oidc\_for\_load\_balancer\_controller](#module\_iam\_assumable\_role\_with\_oidc\_for\_load\_balancer\_controller) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | ~> 3.0 |
| <a name="module_iam_assumable_role_with_oidc_for_route53"></a> [iam\_assumable\_role\_with\_oidc\_for\_route53](#module\_iam\_assumable\_role\_with\_oidc\_for\_route53) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.aws_load_balancer_controller_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.eks_cluster_autoscaler_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.eks_dns_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [helm_release.rime_kube_system](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_secret.docker-secrets](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [local_file.rime_kube_system](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster that the autoscaler is being installed into. | `string` | n/a | yes |
| <a name="input_create_managed_helm_release"></a> [create\_managed\_helm\_release](#input\_create\_managed\_helm\_release) | Whether to deploy a RIME Helm chart onto the provisioned infrastructure managed by Terraform.<br>  Changing the state of this variable will either install/uninstall the RIME deployment<br>  once the change is applied in Terraform. If you want to install the RIME package manually,<br>  set this to false and use the generated values YAML file to deploy the release<br>  on the provisioned infrastructure. | `bool` | `false` | no |
| <a name="input_docker_credentials"></a> [docker\_credentials](#input\_docker\_credentials) | Credentials to pass into docker image pull secrets. Has creds for all registries. Must be structured like so:<br>  [{<br>    docker-server= "",<br>    docker-username="",<br>    docker-password="",<br>    docker-email=""<br>  }] | `list(map(string))` | n/a | yes |
| <a name="input_docker_registry"></a> [docker\_registry](#input\_docker\_registry) | The name of the Docker registry that holds the images for the chart. | `string` | `"docker.io"` | no |
| <a name="input_docker_secret_name"></a> [docker\_secret\_name](#input\_docker\_secret\_name) | The name of the Kubernetes secret used to pull the Docker image for RIME. | `string` | `"rimecreds"` | no |
| <a name="input_domains"></a> [domains](#input\_domains) | The domain to use for all exposed rime services. | `list(string)` | n/a | yes |
| <a name="input_enable_cert_manager"></a> [enable\_cert\_manager](#input\_enable\_cert\_manager) | enable deployment of cert-manager | `bool` | `true` | no |
| <a name="input_helm_values_output_dir"></a> [helm\_values\_output\_dir](#input\_helm\_values\_output\_dir) | The directory where to write the generated values YAML file used to configure the Helm release.<br>  A Helm chart "$helm\_values\_output\_dir/rime\_kube\_system\_values.yaml"<br>  will be created. | `string` | `""` | no |
| <a name="input_install_cluster_autoscaler"></a> [install\_cluster\_autoscaler](#input\_install\_cluster\_autoscaler) | Whether or not to install the cluster autoscaler. If not installed, we expect there to be enough compute to run stress tests without autoscaling. | `bool` | `false` | no |
| <a name="input_install_external_dns"></a> [install\_external\_dns](#input\_install\_external\_dns) | Whether or not to install external dns. If not installed we expect some way to provision dns records on your cloud provider. | `bool` | `false` | no |
| <a name="input_install_lb_controller"></a> [install\_lb\_controller](#input\_install\_lb\_controller) | Whether or not to install the aws lb controller. If you do not install the lb controller or already have it present in your cluster, you will have to manually configure ALBs for ingress. | `bool` | `true` | no |
| <a name="input_install_metrics_server"></a> [install\_metrics\_server](#input\_install\_metrics\_server) | Whether or not to install the metrics server. If you do not install the metrics server, you will not be able to use autoscaling | `bool` | `true` | no |
| <a name="input_manage_namespace"></a> [manage\_namespace](#input\_manage\_namespace) | Whether or not to manage the namespace we are installing into.<br>  This will create the namespace(if applicable), setup docker credentials as a<br>  kubernetes secret etc. Turn this flag off if you have trouble connecting to<br>  k8s from your terraform environment. | `bool` | `true` | no |
| <a name="input_oidc_provider_url"></a> [oidc\_provider\_url](#input\_oidc\_provider\_url) | URL to the OIDC provider for IAM assumable roles used by K8s. | `string` | n/a | yes |
| <a name="input_override_values_file_path"></a> [override\_values\_file\_path](#input\_override\_values\_file\_path) | Optional file path to override values file for the rime helm release.<br>  Values produced by the terraform module will take precedence over these values. | `string` | `""` | no |
| <a name="input_resource_name_suffix"></a> [resource\_name\_suffix](#input\_resource\_name\_suffix) | A suffix to name the IAM policy and role with. | `string` | n/a | yes |
| <a name="input_rime_helm_repository"></a> [rime\_helm\_repository](#input\_rime\_helm\_repository) | Helm Repository URL where the requested RIME chart for is located`.` | `string` | n/a | yes |
| <a name="input_rime_version"></a> [rime\_version](#input\_rime\_version) | The version of the RIME software to be installed. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only. | `map(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->