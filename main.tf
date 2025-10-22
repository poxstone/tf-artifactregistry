module "cloud_run_module_01" {
  source          = "./artifact_module/"
  project         = "bluetab-colombia-data-qa"
  image_name      = "image-test01"
  repository_name = "gcf-artifacts"
  region          = "us-central1"
  description     = "test"
  source_path     = "src/artifact_registry/app/"
  bucket_source   = "bluetab-colombia-data-qa-tmp"
}


