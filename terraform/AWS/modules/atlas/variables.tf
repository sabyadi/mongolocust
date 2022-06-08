variable "region" {
  type        = string
  description = "AWS Region"
}

variable "atlasRegion" {
  type        = string
  description = "AWS Region"
}

variable "publicKey" {
  type        = string
  description = "Atlas Public API key with Project Owner role"
}

variable "privateKey" {
  type        = string
  description = "Atlas Private API key with Project Owner role"
}

variable "projectId" {
  type        = string
  description = "Atlas project id which will hold the load test cluster"
}

variable "numShards" {
  type        = number
  description = "number of shards to be deployed on Atlas"
}

variable "majorVersion" {
  type        = string
  description = "Major release of MongoDB to be deployed on Atlas"
}

variable "mSize" {
  type        = string
  description = "Instance size of MongoDB Cluster e.g. 'M30'"
}


variable "awsVpcId" {
  type        = string
  description = "ID of the VPC on AWS used for the private endpoint and locust nodes"
}

variable "awsSubnetId" {
  type        = string
  description = "ID of the subnet on AWS used for the private endpoint and locust nodes"
}

variable "retryableWritesEnabled" {
  type        = bool
  description = "Boolean if retryable writes should be enabled"
  default     = true
}

variable "writeConcern" {
  type        = string
  description = "Which write concern should be used during the load test"
  default     = "majority"
}

variable "diskSizeGb" {
  type        = number
  description = "Disk size of Atlas Cluster in GB"
}
