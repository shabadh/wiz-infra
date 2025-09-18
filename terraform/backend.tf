terraform {
  backend "gcs" {
    bucket = "wiz-infra-dev"
    prefix = "terraform/state"
  }
}