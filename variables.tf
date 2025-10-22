# El ID del proyecto de GCP donde se desplegarán los recursos
variable "project_id" {
  description = "El ID del proyecto de GCP"
  type        = string
  default = "project"
}

# La región de GCP
variable "region" {
  description = "La región de GCP para los recursos"
  type        = string
  default     = "us-central1"
}

# Nombre del repositorio de Artifact Registry
variable "repository_name" {
  description = "Nombre único para el repositorio de Artifact Registry"
  type        = string
  default     = "gcf-artifacts-gemini"
}

# Nombre de la imagen Docker final
variable "image_name" {
  description = "Nombre para la imagen Docker (por ejemplo, my-app-image)"
  type        = string
  default     = "docker-image-test"
}
