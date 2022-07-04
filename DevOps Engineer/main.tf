provider "google" {
  credentials = file("C:/Users/Barath Balu/Downloads/studious-metric-355208-a11afc50b17f.json")
  project     = "studious-metric-355208"
  region      = "australia-southeast1"
  zone        = "australia-southeast1-c"
}

locals{
  apis = ["compute.googleapis.com", "cloudresourcemanager.googleapis.com"]
}
resource "google_project_service" "project" {
  for_each = toset(local.apis)
  service = each.value
}

resource "google_compute_network" "vpc_network" {
  name = "prod-vpc-network"
  auto_create_subnetworks = false
  depends_on = [
    resource.google_project_service.project
  ]
}

resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name          = "core-subnet"
  ip_cidr_range = "10.2.0.0/24"
  region        = "australia-southeast1"
  network       = google_compute_network.vpc_network.id
#  secondary_ip_range {
#    range_name    = "tf-test-secondary-range-update1"
#    ip_cidr_range = "192.168.10.0/24"
#  }
}

/*
resource "google_compute_instance" "create_instances" {
  name                = local.vm_name
  description         = "Instance ${local.vm_prefix} created using ${var.tenancy_module.tla}"
  project             = data.google_project.app_project[var.override_google_project].project_id
  zone                = var.instance_zone
  tags                = local.local_tags
  labels              = var.override_google_project != "default" ? merge(var.tenancy_module.imported_project[data.google_project.app_project[var.override_google_project].project_id].labels, local.vm_labels) : merge(var.tenancy_module.labels, local.vm_labels)
  machine_type        = var.instance_template_machine_type
  can_ip_forward      = var.can_ip_forward
  metadata            = local.local_lookup_metadata
  deletion_protection = var.instance_deletion_protection

  depends_on = [
    google_project_service.app_project_storage_json_service,
    google_project_service.app_project_storage_service,
    google_storage_bucket_iam_member.member
  ]

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.image.self_link
      size  = local.boot_disk_size
      type  = var.disk_type
    }
    auto_delete = var.auto_delete
  }

  lifecycle {
    ignore_changes = [
      # Ignoring boot_disk attributes as they are not changable after launch, and cause re-deployment
      boot_disk[0].initialize_params[0].image,
      boot_disk[0].initialize_params[0].size,
      boot_disk[0].initialize_params[0].type,
      can_ip_forward,
      description
    ]
  }


  dynamic "attached_disk" {
    for_each = google_compute_disk.disk_rhel_default
    content {
      source = attached_disk.value.self_link
    }
  }

 
  network_interface {
    subnetwork         = "gcp-wow-vpc-${local.local_env}-subnet-core"
    subnetwork_project = local.local_region_subnet
  }

  service_account {
    email  = var.override_google_project != "default" ? var.override_service_account_email : "project-service-account@${data.google_project.app_project[var.override_google_project].project_id}.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}
*/