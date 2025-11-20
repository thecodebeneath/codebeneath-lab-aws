variable bootstrap_brokers_public_sasl_iam {
  type        = string
  default     = ""
  description = "A list of the bootstrap broker endpoints for the MSK cluster, with SASL IAM authentication enabled. This should be provided as a comma-separated string when running Terraform."
}
