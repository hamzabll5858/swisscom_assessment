
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
resource "google_compute_network" "main" {
  name                            = "assessment-vpc"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false

  depends_on = [
    google_project_service.compute,
    google_project_service.container
  ]
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork
resource "google_compute_subnetwork" "private" {
  name                     = "assessment-private"
  ip_cidr_range            = "10.0.0.0/18"
  region                   = "us-central1"
  network                  = google_compute_network.main.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "k8s-pod-range"
    ip_cidr_range = "10.48.0.0/14"
  }
  secondary_ip_range {
    range_name    = "k8s-service-range"
    ip_cidr_range = "10.52.0.0/20"
  }
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router
resource "google_compute_router" "router" {
  name    = "assessment-router"
  region  = "us-central1"
  network = google_compute_network.main.id
}


# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat
resource "google_compute_router_nat" "nat" {
  name   = "assessment-nat"
  router = google_compute_router.router.name
  region = "us-central1"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option             = "MANUAL_ONLY"

  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  nat_ips = [google_compute_address.nat.self_link]
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address
resource "google_compute_address" "nat" {
  name         = "nat"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  depends_on = [google_project_service.compute]
}


# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall
resource "google_compute_firewall" "allow-all" {
  name    = "allow-all"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  lifecycle {
    create_before_destroy = true
  }

  source_ranges = ["0.0.0.0/0"]
}


resource "google_service_account" "packer" {
  account_id = "packer"
}

resource "google_project_iam_member" "compute_member" {
  project = var.project_id
  role = "roles/compute.instanceAdmin.v1"
  member = "serviceAccount:${google_service_account.packer.email}"
}

resource "google_project_iam_member" "iam_member" {
  project = var.project_id
  role = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_service_account.packer.email}"
}

resource "google_project_iam_member" "iap_member" {
  project = var.project_id
  role = "roles/iap.tunnelResourceAccessor"
  member = "serviceAccount:${google_service_account.packer.email}"
}

resource "google_project_iam_member" "storage_viewer" {
  count = 1
  project = var.project_id
  role = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.packer.email}"
}

resource "google_project_iam_member" "artifact_reader" {
  count = 1
  project = var.project_id
  role = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.packer.email}"
}

resource "google_container_registry" "registry" {
  project  = var.project_id
  location = "US"
}

resource "google_storage_bucket_iam_member" "viewer" {
  bucket = google_container_registry.registry.id
  role = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.packer.email}"
}
