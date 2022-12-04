module "mig_template" {
  source     = "terraform-google-modules/vm/google//modules/instance_template"
  version    = "~> 7.9"
  network    = var.vpc_id
  subnetwork = var.subnet_id
  disk_size_gb = "20"
  machine_type = "e2-medium"
  service_account = {
    email  = ""
    scopes = ["cloud-platform"]
  }
  project_id           = var.project_id
  name_prefix          = "assessment-group1"
  source_image         = "assessment-ubuntu-ami"
  source_image_project = "root-project-5858"
  tags = [
    "assessment-group1",
  ]
}

module "mig" {
  source            = "terraform-google-modules/vm/google//modules/mig"
  version           = "~> 7.9"
  instance_template = module.mig_template.self_link
  project_id        = var.project_id
  region            = var.region
  hostname          = "assessment-group1"
  target_size       = var.target_size
  distribution_policy_zones  = ["us-central1-a", "us-central1-b", "us-central1-c"]
  named_ports = [{
    name = "http",
    port = 80
  }]
  network    = var.vpc_id
  subnetwork = var.subnet_id
  update_policy = [{
    type                           = "PROACTIVE"
    instance_redistribution_type   = "PROACTIVE"
    minimal_action                 = "REPLACE"
    most_disruptive_allowed_action = "REPLACE"

    max_surge_fixed                = 3
    max_unavailable_fixed          = 3

    min_ready_sec                  = 50
    replacement_method             = "SUBSTITUTE"
  }]
}

module "gce-lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 6.0"
  name    = "assessment-lb"
  project = var.project_id
  target_tags = [
    "assessment-group1",
  ]
  firewall_networks = [var.vpc_id]

  backends = {
    default = {

      description                     = null
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 10
      connection_draining_timeout_sec = null
      enable_cdn                      = false
      security_policy                 = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null
      custom_response_headers         = null

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/"
        port                = 80
        host                = null
        logging             = null
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group                        = module.mig.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
    }
  }
}