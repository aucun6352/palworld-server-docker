terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  credentials = file("../../credentials.json")

  project = ""
  region = "asia-northeast3"
  zone   = "asia-northeast3-a"
}

resource "google_compute_network" "vpc_network" {
  name = "palworld-vpc"
}

resource "google_compute_network_firewall_policy" "basic_network_firewall_policy" {
  name        = "pal-network-fireall-policy"
}

resource "google_compute_network_firewall_policy_rule" "primary" {
  action = "allow"
  direction = "INGRESS"
  firewall_policy = google_compute_network_firewall_policy.basic_network_firewall_policy.name
  priority = 1000

  match  {
    src_ip_ranges = [ "0.0.0.0/0" ]
    layer4_configs {
      ip_protocol = "tcp"
      ports = [ 8211, 27015, 22 ]
    }

    layer4_configs {
      ip_protocol = "udp"
      ports = [ 8211, 27015 ]
    }
  }
}

resource "google_compute_network_firewall_policy_association" "primary" {
  name = "association"
  attachment_target = google_compute_network.vpc_network.id
  firewall_policy =  google_compute_network_firewall_policy.basic_network_firewall_policy.name
}

resource "google_service_account" "default" {
  account_id   = "instance-sa"
  display_name = "Custom SA for VM Instance"
}

resource "google_storage_bucket" "palworld" {
  name          = "palworld-server-file"
  location      = "ASIA"
  force_destroy = false

  public_access_prevention = "enforced"
}

resource "google_storage_bucket_object" "picture" {
  name   = ".env"
  source = "../.env"
  bucket = google_storage_bucket.palworld.name
}

# resource "google_compute_instance" "palworld_instance" {
#   name         = "pal-server-instance"
#   machine_type     = "c2-standard-4"


#   boot_disk {
#     initialize_params {
#       size = 40
#       type = "pd-ssd"
#       image = "cos-cloud/cos-stable"
#     }

#     mode = "READ_WRITE"
#   }

#   labels = {
#     goog-ec-src = "vm_add-tf"
#   }

#   network_interface {
#     network = google_compute_network.vpc_network.name

#     access_config {
#       // Ephemeral public IP
#     }
#   }

#   metadata = {
#     user-data = file("${path.module}/cloud-config.yaml") 
#   }

#   # service_account {
#   #   email  = google_service_account.default.email
#   #   scopes = ["default"]
#   # }
# }