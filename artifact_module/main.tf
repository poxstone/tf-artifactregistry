locals {
  fc_prefix_name = var.image_name
  str_date       = formatdate("YYMMDDhhmmss", timestamp())
}

data "archive_file" "zip_cloud_function" {
  type        = "zip"
  source_dir  = var.source_path
  output_path = "${local.fc_prefix_name}.zip"
}

resource "google_storage_bucket_object" "obj_function" {
  name = "${local.fc_prefix_name}.zip#${data.archive_file.zip_cloud_function.output_md5}"
  #  name       = "${local.fc_prefix_name}.zip"
  bucket     = var.bucket_source
  source     = data.archive_file.zip_cloud_function.output_path
  depends_on = [data.archive_file.zip_cloud_function]
}

resource "null_resource" "cloudbuild_trigger" {
  # Usamos un timestamp para forzar la ejecución en cada 'apply'
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "gcloud builds submit . --config cloudbuild.yaml --project=\"${var.project}\" --substitutions=_AR_REGION=\"${var.region}\",_REPOSITORY_NAME=\"${var.repository_name}\",_IMAGE_NAME=\"${var.image_name}\",SHORT_SHA=${substr(sha1(timestamp()), 0, 7)}"
  }

  depends_on = [google_storage_bucket_object.obj_function]
}