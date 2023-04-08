<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | > 0.14, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.75.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.62.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.rime_domain_cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.rime_domain_cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_route53_record.rime_domain_cert_validation_records](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain"></a> [domain](#input\_domain) | Domain to create a cert for. This can also be a wildcard cert. Must be a child of the registered domain. | `string` | n/a | yes |
| <a name="input_registered_domain_zone_id"></a> [registered\_domain\_zone\_id](#input\_registered\_domain\_zone\_id) | Zone ID to place cert validation records. This should be a valid registered route 53 domain if you want it to | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_cert_arn"></a> [acm\_cert\_arn](#output\_acm\_cert\_arn) | n/a |
<!-- END_TF_DOCS -->