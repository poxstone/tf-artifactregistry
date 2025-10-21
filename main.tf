# 1. Obtener datos del proyecto para la cuenta de servicio (Service Account) de Cloud Build
data "google_project" "project" {}

# 2. Crear el repositorio en Artifact Registry (para almacenar imágenes Docker)
resource "google_artifact_registry_repository" "docker_repo" {
  provider      = google
  project       = var.project_id
  location      = var.region
  repository_id = var.repository_name
  description   = "Repositorio Docker para la imagen ${var.image_name}"
  format        = "DOCKER"

  depends_on = [google_project_service.required_services]
}

# 3. Asignar el rol de 'Artifact Registry Writer' a la Cuenta de Servicio de Cloud Build
# Esto le permite a Cloud Build subir (push) imágenes al nuevo repositorio.
resource "google_project_iam_member" "cloudbuild_ar_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"

  depends_on = [
    google_artifact_registry_repository.docker_repo,
    google_project_service_identity.cloudbuild_sa
  ]
}

# 3.1 Asignar el rol de 'Cloud Run Admin' a la Cuenta de Servicio de Cloud Build
# Esto le permite a Cloud Build desplegar servicios en Cloud Run.
resource "google_project_iam_member" "cloudbuild_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"

  depends_on = [
    google_project_service_identity.cloudbuild_sa
  ]
}

# 4. Disparar la compilación de Cloud Build
resource "null_resource" "cloudbuild_trigger" {
  # Usamos un timestamp para forzar la ejecución en cada 'apply'
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "gcloud builds submit . --config cloudbuild.yaml --project=${var.project_id} --substitutions=_AR_REGION=${var.region},_REPOSITORY_NAME=${var.repository_name},_IMAGE_NAME=${var.image_name},SHORT_SHA=${substr(sha1(timestamp()), 0, 7)}"
  }

  depends_on = [
    google_project_iam_member.cloudbuild_ar_writer,
    google_project_iam_member.cloudbuild_run_admin,
  ]
}

# Output para mostrar la URL del repositorio
output "artifact_registry_url" {
  description = "URL del repositorio de Artifact Registry para la imagen Docker"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_name}"
}
