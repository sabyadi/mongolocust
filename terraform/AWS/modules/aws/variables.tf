variable "region" {
  type        = string
  description = "AWS Region"
}

variable "vpcId" {
  type        = string
  description = "ID of the VPC on AWS used for the private endpoint and locust nodes"
}

variable "subnetId" {
  type        = string
  description = "ID of the subnet on AWS used for the private endpoint and locust nodes"
}

variable "atlasServiceName" {
  type        = string
  description = "ID of the subnet on AWS used for the private endpoint and locust nodes"
}
