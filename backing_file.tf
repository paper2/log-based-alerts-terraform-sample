locals {
  project_id =<Your GCP Project ID>
  notification_channel_email = <Your email for test notification channel>
  name_suffix = random_pet.suffix.id
}

resource "random_pet" "suffix" {
  length = 1
}

provider "google" {
  project     = local.project_id
  region      = "asia-northeast1"
  zone        = "asia-northeast1-a"
}
