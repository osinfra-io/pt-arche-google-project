# Output Values
# https://opentofu.org/docs/language/values/outputs

output "cis_2_2_logging_bucket_locked" {
  description = "Whether the default logging bucket is locked"
  value       = module.google_project.cis_2_2_logging_bucket_locked
}
