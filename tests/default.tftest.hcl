mock_provider "google" {
  mock_resource "google_logging_project_sink" {
    defaults = {
      writer_identity = "serviceAccount:mock-cis-2-2-logging-sink@mock.iam.gserviceaccount.com"
    }
  }
}

mock_provider "google-beta" {
  mock_resource "google_project_service_identity" {
    defaults = {
      email = "service-mock@gcp-sa-logging.iam.gserviceaccount.com"
    }
  }
}

run "default" {
  command = apply

  module {
    source = "./tests/fixtures/default"
  }

  variables {
    cis_2_2_logging_sink_project_id = "mock-logging-sink-project"
  }
}

run "logging" {
  command = plan

  module {
    source = "./tests/fixtures/logging"
  }

  assert {
    condition     = output.cis_2_2_logging_bucket_locked
    error_message = "The CIS 2.2 logging bucket must be locked by default"
  }
}

variables {
  environment = "sandbox"
}
