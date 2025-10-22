output "artifact_registry_url" {
  description = "URL del repositorio de Artifact Registry para la imagen Docker"
  value       = "${var.region}-docker.pkg.dev/${var.project}/${var.repository_name}/${var.image_name}:${data.archive_file.zip_cloud_function.output_md5}"
}
