variable "region" {
  type        = string
  description = "REGION"
  default     = "us-central1"
}

variable "project_id" {
  type        = string
  description = "Project ID"
  default     = "root-project-5858"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
  default     = ""
}

variable "subnet_id" {
  type        = string
  description = "SUBNET ID"
  default     = ""
}

variable "target_size" {
  type        = string
  description = "MIG TARGET SIZE ID"
  default     = "2"
}