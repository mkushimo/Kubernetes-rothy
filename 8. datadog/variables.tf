
variable "datadog_api_key" {
  type    = string
  default = "5378ab53f298280746de0341769158b1"
}

variable "datadog_app_key" {
  type    = string
  default = "3cd2e566f77cc748a33661d10c7b33ce45c6a38e"
}

variable "datadog_api_url" {
  type    = string
  default = "https://api.us5.datadoghq.com/"
}

variable "application_name" {
  type        = string
  description = "Application Name"
  default     = "demo"
}

variable "datadog_site" {
  type        = string
  description = "Datadog Site Parameter"
  default     = "us5.datadoghq.com"
}




