terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "1.0.1"
    }
  }
  required_version = ">= 1.0.8"
}



resource "mongodbatlas_cluster" "locust_cluster" {
  project_id   = var.projectId
  name         = "locust-cluster"
  cluster_type = "REPLICASET"
  replication_specs {
    num_shards = var.numShards
    regions_config {
      region_name     = var.atlasRegion
      electable_nodes = 3
      priority        = 7
      read_only_nodes = 0
    }
  }
  cloud_backup                 = false
  auto_scaling_disk_gb_enabled = true
  mongo_db_major_version       = var.majorVersion

  //Provider Settings "block"
  provider_name               = "AWS"
  disk_size_gb                = var.diskSizeGb
  provider_instance_size_name = var.mSize
}

resource "mongodbatlas_privatelink_endpoint" "aws_endpoint" {
  project_id    = var.projectId
  provider_name = "AWS"
  region        = var.region
}

module "aws_network" {
  source           = "./../aws"
  region           = var.region
  vpcId            = var.awsVpcId
  subnetId         = var.awsSubnetId
  atlasServiceName = mongodbatlas_privatelink_endpoint.aws_endpoint.endpoint_service_name
}

resource "mongodbatlas_privatelink_endpoint_service" "aws_endpoint_service" {
  project_id          = mongodbatlas_privatelink_endpoint.aws_endpoint.project_id
  private_link_id     = mongodbatlas_privatelink_endpoint.aws_endpoint.private_link_id
  endpoint_service_id = module.aws_network.endpoint_service_id
  provider_name       = "AWS"
}

resource "random_string" "password" {
  length  = 16
  special = false
}

resource "mongodbatlas_database_user" "demo-user" {
  username           = "demo-user"
  password           = random_string.password.result
  project_id         = var.projectId
  auth_database_name = "admin"

  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }
}

output "connection_string" {
  value = join("", [
    replace("${mongodbatlas_cluster.locust_cluster.connection_strings[0].private_endpoint[0].srv_connection_string}", "mongodb+srv://", "mongodb+srv://demo-user:${random_string.password.result}@"),
  "/?retryWrites=${var.retryableWritesEnabled}&w=${var.writeConcern}"])
  description = "Connection string for aws endpoint"
  depends_on  = [mongodbatlas_privatelink_endpoint_service.aws_endpoint_service]
}

