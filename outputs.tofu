# Output Values
# https://opentofu.org/docs/language/values/outputs

output "cis_2_2_logging_sink_project_id" {
  description = "The CIS 2.2 logging sink benchmark project ID"
  value       = local.cis_2_2_logging_sink_project_id
}

output "id" {
  description = "The project ID"
  value       = google_project.this.project_id
}

output "number" {
  description = "The project number"
  value       = google_project.this.number
}

output "unique_writer_identity" {
  description = "The unique identity associated with this sink"
  value       = google_logging_project_sink.cis_2_2_logging_sink.writer_identity
}
