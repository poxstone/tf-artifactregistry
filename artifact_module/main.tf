resource "null_resource" "cloudbuild_trigger" {
  # Usamos un timestamp para forzar la ejecución en cada 'apply'
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "gcloud builds submit . --config cloudbuild.yaml --project=${var.project} --substitutions=_AR_REGION=${var.region},_REPOSITORY_NAME=${var.repository_name},_IMAGE_NAME=${var.image_name},SHORT_SHA=${substr(sha1(timestamp()), 0, 7)}"
  }

  depends_on = []
}
