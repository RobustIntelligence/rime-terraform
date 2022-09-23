output "cluster_name" {
  value = module.eks.cluster_id
}

output "storage_class_name" {
  value = var.expandable_storage_class_name
}
