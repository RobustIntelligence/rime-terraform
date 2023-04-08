<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | > 0.14, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.60.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_artifact_registry_repository.managed-image-repo](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_artifact_registry_repository_iam_member.member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_member) | resource |
| [google_artifact_registry_repository_iam_member.node-repo-reader-member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_member) | resource |
| [google_artifact_registry_repository_iam_member.pusher-role-membership](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_member) | resource |
| [google_project_iam_custom_role.docker-admin-role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_service_account.image-pusher-sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.managed-image-repo-admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.image-pusher-sa-workload-identity-iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_service_account_iam_member.managed-image-repo-admin-workload-identity-iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gcp_config"></a> [gcp\_config](#input\_gcp\_config) | A configuration containing parameters specific to GCP | <pre>object({<br>    location = string<br>    project  = string<br>    // TODO: make into a list of strings called repo_reader_sa_emails<br>    node_sa_email = string<br>  })</pre> | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace where the RIME Helm chart is to be installed. | `string` | n/a | yes |
| <a name="input_repo_base_name"></a> [repo\_base\_name](#input\_repo\_base\_name) | Base name used for the repository created and managed by the RIME Image Registry service. Will also be joined with namespace and resource suffix. | `string` | `"rime-managed-images"` | no |
| <a name="input_resource_name_suffix"></a> [resource\_name\_suffix](#input\_resource\_name\_suffix) | A suffix to name the IAM policy and role with. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gar_config"></a> [gar\_config](#output\_gar\_config) | n/a |
| <a name="output_managed-image-repo-admin-annotation"></a> [managed-image-repo-admin-annotation](#output\_managed-image-repo-admin-annotation) | n/a |
| <a name="output_managed-image-repo-builder-annotation"></a> [managed-image-repo-builder-annotation](#output\_managed-image-repo-builder-annotation) | n/a |
<!-- END_TF_DOCS -->