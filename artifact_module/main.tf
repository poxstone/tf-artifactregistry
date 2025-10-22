locals {
  fc_prefix_name = var.image_name
  str_date       = formatdate("YYMMDDhhmmss", timestamp())
}

data "archive_file" "zip_cloud_function" {
  type        = "zip"
  source_dir  = var.source_path
  output_path = "${local.fc_prefix_name}.zip"
}

resource "google_storage_bucket_object" "obj_app_code" {
  name       = "${local.fc_prefix_name}.zip#${data.archive_file.zip_cloud_function.output_md5}"
  bucket     = var.bucket_source
  source     = data.archive_file.zip_cloud_function.output_path
  depends_on = [data.archive_file.zip_cloud_function]
}

resource "null_resource" "cloudbuild_build_trigger" {
  triggers = {
    always_run = "${data.archive_file.zip_cloud_function.output_md5}"
  }

  provisioner "local-exec" {
    command = "gcloud builds submit --no-source --config ${path.module}/cloudbuild.yaml --project=\"${var.project}\" --substitutions=_AR_REGION=\"${var.region}\",_REPOSITORY_NAME=\"${var.repository_name}\",_IMAGE_NAME=\"${var.image_name}\",SHORT_SHA=${data.archive_file.zip_cloud_function.output_md5},_BUCKET_SOURCE=\"${var.bucket_source}\",_ZIP_OBJECT=\"${google_storage_bucket_object.obj_app_code.name}\""
  }

  depends_on = [google_storage_bucket_object.obj_app_code]
}