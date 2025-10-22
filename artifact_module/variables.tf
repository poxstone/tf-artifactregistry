variable "image_name" {
  type        = string
  description = "repository name"
}

variable "repository_name" {
  type        = string
  description = "repository name"
}

variable "project" {
  type        = string
  description = "Project ID for host schedule"
}

variable "description" {
  type        = string
  description = "Description for table"
  default     = ""
}

variable "region" {
  type        = string
  description = "Location Regional or Multiregional"
  default     = "us-central"
}

variable "version" {
  type        = string
  description = "version para la imagen"
  default     = null
}

variable "service_account_name" {
  type        = string
  description = "Service Account for run query"
  default     = null
}
