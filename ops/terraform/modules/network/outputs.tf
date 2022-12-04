output "vpc_id" {
  description = "VPC ID"
  value = google_compute_network.main.id
}

output "subnet_id" {
  description = "VPC ID"
  value = google_compute_subnetwork.private.id
}

output "packer_email" {
  description = "PACKER SA EMAIL"
  value = google_service_account.packer.email
}