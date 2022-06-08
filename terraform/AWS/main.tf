terraform {

  required_version = ">= 1.0.8"
}

provider "aws" {
  region  = var.region
  profile = var.awsProfile
}

module "atlasCluster" {
  source                 = "./modules/atlas"
  region                 = var.region
  atlasRegion            = var.atlasRegion
  publicKey              = var.atlasPublicApiKey
  privateKey             = var.atlasPrivateApiKey
  projectId              = var.atlasProjectId
  numShards              = var.atlasNumShards
  majorVersion           = var.atlasmajorVersion
  mSize                  = var.atlasMSize
  awsVpcId               = var.awsVpcId
  awsSubnetId            = var.awsSubnetId
  retryableWritesEnabled = var.retryableWritesEnabled
  writeConcern           = var.writeConcern
  diskSizeGb             = var.diskSizeGb
}

module "locust" {
  source                    = "./modules/locust_infrastructure"
  region                    = var.region
  locustMasterInstanceType = var.locustMasterInstanceType
  locustWorkerInstanceType  = var.locustWorkerInstanceType
  keyName                   = var.keyName
  keyPath                   = var.keyPath
  awsSubnetId               = var.awsSubnetId
  workernodeCount           = var.workernodeCount
}

output "locust_UI" {
  value = module.locust.master_public_dns
}

output "worker_per_node" {
  value = var.workersPerNode
}

output "locust_master_dns" {
  value = module.locust.master_public_dns
}

output "locust_workernodes_dns" {
  value = module.locust.workerNodes_public_dns
}

output "ssh_keyfile_path" {
  value = var.keyPath
}

output "locust_files" {
  value = join(",", var.locustFiles)
}

output "locust_execution_file" {
  value = var.locustExecuteFile
}

output "connection_string" {
  value = module.atlasCluster.connection_string
}