terraform {
  source = "../../modules/compute"
}

include {
  path = find_in_parent_folders()
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  project_id  = "root-project-5858"
  vpc_id      = dependency.network.outputs.vpc_id
  subnet_id   = dependency.network.outputs.subnet_id
  target_size = "2"
}