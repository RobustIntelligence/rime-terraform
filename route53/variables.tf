variable "registered_domain_zone_id" {
  description = "Zone ID to place cert validation records. This should be a valid registered route 53 domain if you want it to "
  type        = string
}

variable "domain" {
  description = "Domain to create a cert for. This can also be a wildcard cert. Must be a child of the registered domain."
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only."
  type        = map(string)
  default     = {}
}
