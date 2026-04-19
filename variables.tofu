# Input Variables
# https://opentofu.org/docs/language/values/variables

variable "billing_account" {
  description = "The alphanumeric ID of the billing account this project belongs to"
  type        = string
}

variable "budget_notification_email" {
  description = "The email address to send budget notifications to"
  type        = string
  default     = "billing-admins@osinfra.io"
}

variable "cis_2_2_logging_bucket_locked" {
  description = "Boolean to enable CIS 2.2 logging bucket lock"
  type        = bool
  default     = true
}

variable "cis_2_2_logging_sink_project_id" {
  description = "The CIS 2.2 logging sink project ID"
  type        = string
  default     = ""
}

variable "deletion_policy" {
  description = "The deletion policy for the project"
  type        = string
  default     = "PREVENT"
}

variable "folder_id" {
  description = "The numeric ID of the folder this project should be created under. Only one of `org_id` or `folder_id` may be specified"
  type        = string
}

variable "key_ring_location" {
  description = "The location of the key ring to create"
  type        = string
  default     = "us"
}

variable "labels" {
  description = "A map of key/value pairs to assign to the resources being created"
  type        = map(string)
  default     = {}
}

variable "monthly_budget_amount" {
  description = "The monthly budget amount in USD to set for the project"
  type        = number
  default     = 5
}

variable "prefix" {
  description = "The team prefix for example: `ops` (Operations), `sec` (Security)"
  type        = string
  default     = "test"
}

variable "random_project_id" {
  description = "If true, a random hex value with a prefix of tf will be added to the `project_id`"
  type        = bool
  default     = true
}

variable "security_notification_email" {
  description = "The email address to send security notifications to"
  type        = string
  default     = "security@osinfra.io"
}

variable "services" {
  description = "A list of services to enable in the project"
  type        = list(string)
  default     = []
}
