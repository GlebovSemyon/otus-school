locals {
  cloud_id           = "${var.cloud_id}" 
  folder_id          = "${var.folder_id}" 
  zone               = "ru-central1-a"
}
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = local.zone
  cloud_id  = local.cloud_id
  folder_id = local.folder_id
}
