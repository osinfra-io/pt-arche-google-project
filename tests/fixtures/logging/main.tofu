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

  billing_account = "000000-000000-000000"
  folder_id       = "0000000000000"

  labels = {
    "mock-key" = "mock-value"
  }

  prefix = "mock"
}
