# Required Providers
# https://opentofu.org/docs/language/providers/requirements

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    google-beta = {
      source = "hashicorp/google-beta"
    }
  }
}

# Google Project
# https://github.com/osinfra-io/pt-arche-google-project

module "google_project" {
  source = "../../../"

  billing_account                 = "000000-000000-000000"
  cis_2_2_logging_sink_project_id = var.cis_2_2_logging_sink_project_id
  description                     = "mock"
  folder_id                       = "0000000000000"

  labels = {
    "mock-key" = "mock-value"
  }

  prefix = "mock"

  services = [
    "mock.googleapis.com"
  ]
}
