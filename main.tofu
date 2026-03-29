# Billing Budget Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/billing_budget

resource "google_billing_budget" "project" {
  all_updates_rule {
    monitoring_notification_channels = [
      google_monitoring_notification_channel.this["budget"].name
    ]
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = var.monthly_budget_amount
    }
  }

  billing_account = var.billing_account

  budget_filter {
    projects = [local.billing_budget_project_filter]
  }

  display_name = local.billing_budget_display_name

  threshold_rules {
    spend_basis       = "CURRENT_SPEND"
    threshold_percent = 0.50
  }

  threshold_rules {
    spend_basis       = "CURRENT_SPEND"
    threshold_percent = 0.75
  }

  threshold_rules {
    spend_basis       = "CURRENT_SPEND"
    threshold_percent = 1.0
  }
}

# Project Metadata Item Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/compute_project_metadata_item

# CIS 4.4 Ensure OS login is enabled for a project.
# Enabling OS login binds SSH certificates to IAM users and facilitates effective SSH certificate management.

resource "google_compute_project_metadata_item" "enable_oslogin" {
  depends_on = [
    google_project_service.this
  ]

  key     = "enable-oslogin"
  project = google_project.this.project_id
  value   = true
}

# KMS Crypto Key Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/kms_crypto_key

resource "google_kms_crypto_key" "cis_2_2_logging_sink" {
  lifecycle {
    enabled = var.cis_2_2_logging_sink_project_id == ""

    # We can't use the lifecycle block to prevent destroy on this resource for testing purposes.
    # CryptoKeys cannot be deleted from Google Cloud Platform. Destroying a OpenTofu-managed CryptoKey will
    # remove it from state and delete all CryptoKeyVersions, rendering the key unusable, but will not delete
    # the resource from the project. When OpenTofu destroys these keys, any data previously encrypted with
    # these keys will be irrecoverable. For this reason, it is strongly recommended that you add lifecycle
    # hooks to the resource to prevent accidental destruction.

    # prevent_destroy = true
  }

  key_ring        = google_kms_key_ring.this.id
  labels          = var.labels
  name            = "cis-2-2-logging-sink"
  rotation_period = "7776000s"
}

# KMS Crypto Key IAM Member Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member

resource "google_kms_crypto_key_iam_member" "cis_2_2_logging_sink" {
  lifecycle {
    enabled        = var.cis_2_2_logging_sink_project_id == ""
    ignore_changes = [member]
  }

  crypto_key_id = google_kms_crypto_key.cis_2_2_logging_sink.id
  member        = local.logging_service_identity_member
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
}

# KMS Key Ring Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/kms_key_ring

resource "google_kms_key_ring" "this" {
  depends_on = [
    google_project_service.this
  ]

  location = var.key_ring_location
  name     = "default"
  project  = google_project.this.project_id
}

# Logging Metric Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/logging_metric

resource "google_logging_metric" "cis_logging_metrics" {
  for_each = local.cis_logging_metrics

  description = each.value.description
  filter      = each.value.filter
  name        = each.key
  project     = google_project.this.project_id
}

# Project Logging Bucket Config Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/logging_project_bucket_config

resource "google_logging_project_bucket_config" "cis_2_2_logging_sink" {
  lifecycle {
    enabled = var.cis_2_2_logging_sink_project_id == ""
  }

  bucket_id = "cis-2-2-logging-sink"

  cmek_settings {
    kms_key_name = google_kms_crypto_key.cis_2_2_logging_sink.id
  }

  location       = var.key_ring_location
  locked         = var.cis_2_2_logging_bucket_locked
  project        = google_project.this.project_id
  retention_days = 30
}

# We disable _Default logging sink at the organization level to avoid duplicate logs
# https://cloud.google.com/logging/docs/default-settings#disable-default-sink
# gcloud alpha logging settings update --organization=${ORGANIZATION_ID} --disable-default-sink
# gcloud alpha logging settings describe --organization=${ORGANIZATION_ID}

# CIS 2.2 Ensure that sinks are configured for all log entries.
# It is recommended to create a sink that will export copies of all the log entries.

# Project Logging Sink Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/logging_project_sink

resource "google_logging_project_sink" "cis_2_2_logging_sink" {
  depends_on = [
    google_project_service.this
  ]

  destination            = local.cis_2_2_logging_sink_storage_bucket
  name                   = "cis-2-2-logging-sink"
  project                = google_project.this.project_id
  unique_writer_identity = true
}

# Monitoring Alert Policy Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/monitoring_alert_policy

resource "google_monitoring_alert_policy" "cis_logging_metrics" {
  for_each = local.cis_logging_metrics

  combiner = "OR"

  conditions {
    condition_threshold {
      aggregations {
        alignment_period     = "60s"
        cross_series_reducer = "REDUCE_COUNT"
        per_series_aligner   = "ALIGN_DELTA"
      }

      comparison = "COMPARISON_GT"
      duration   = "0s"
      filter     = local.cis_logging_metrics_filters[each.key]
    }

    display_name = google_logging_metric.cis_logging_metrics[each.key].name
  }

  display_name = each.value.displayName

  documentation {
    content   = each.value.description
    mime_type = "text/markdown"
  }

  notification_channels = [
    google_monitoring_notification_channel.this["security"].name
  ]

  project = google_project.this.project_id

  user_labels = local.cis_logging_metrics_user_labels[each.key]
}

# Monitoring Notification Channel Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/monitoring_notification_channel

resource "google_monitoring_notification_channel" "this" {
  for_each = local.monitoring_notification_channels

  description  = each.value.description
  display_name = each.value.display_name
  force_delete = true

  labels = {
    "email_address" = each.value.email_address
  }

  project     = google_project.this.project_id
  type        = "email"
  user_labels = var.labels
}

# Project Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/google_project

# CIS 3.1 Ensure that the default network does not exist in a project.
# The default network has a pre-configured network configuration that is not suitable for production use.

resource "google_project" "this" {
  auto_create_network = false
  billing_account     = var.billing_account
  deletion_policy     = var.deletion_policy
  folder_id           = var.folder_id
  labels              = var.labels
  name                = local.project_id
  project_id          = local.project_id
}

# IAM Audit Config Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_audit_config

# CIS 2.1 Ensure that cloud audit logging is configured properly across all services and all users from a project.
# It is recommended that Cloud Audit Logging is configured to track all admin activities and read, write access to user data.

resource "google_project_iam_audit_config" "cis_2_1" {
  dynamic "audit_log_config" {
    for_each = local.audit_log_config_types

    content {
      log_type = audit_log_config.key
    }
  }

  project = google_project.this.project_id
  service = "allServices"
}

# Project IAM Member Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/google_project_iam

# We do not need to add the role to the project if the log bucket and sync are in the same project.

resource "google_project_iam_member" "cis_2_2" {
  lifecycle {
    enabled = var.cis_2_2_logging_sink_project_id != ""
  }

  member  = google_logging_project_sink.cis_2_2_logging_sink.writer_identity
  project = local.cis_2_2_logging_sink_project_id
  role    = "roles/logging.bucketWriter"
}

# Project Service Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/google_project_service

resource "google_project_service" "this" {
  for_each = local.services

  disable_dependent_services = true
  project                    = google_project.this.project_id
  service                    = each.key
}

# Project Service Identity Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/project_service_identity

resource "google_project_service_identity" "logging" {
  count = local.logging_service_identity_count

  depends_on = [
    google_project_service.this
  ]

  provider = google-beta # Required for google_project_service_identity

  project = google_project.this.project_id
  service = "logging.googleapis.com"
}

# Random ID Resource
# https://search.opentofu.org/provider/hashicorp/random/latest/docs/resources/id

resource "random_id" "this" {
  lifecycle {
    enabled = var.random_project_id
  }

  byte_length = "1"
  prefix      = "tf"
}
