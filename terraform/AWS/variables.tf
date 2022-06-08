variable "region" {
  type        = string
  description = "AWS Region"
}

variable "awsProfile" {
  type = string
  description = "aws profile for EC2 creation"
}

variable "atlasRegion" {
  type        = string
  description = "Region of the Atlas Cluster. Must be in the format 'EU_CENTRAL_1'"
  default = ""
}

variable "locustMasterInstanceType" {
  type        = string
  description = "AWS Instance Type of the locust master"
  default     = "t2.small"
}

variable "locustWorkerInstanceType" {
  type        = string
  description = "AWS Instance Type of the locust workers"
  default     = "t2.small"
}

variable "workernodeCount" {
  type        = number
  description = "Amount of worker nodes to be deployed"
  default     = 1
}

variable "workersPerNode" {
  type        = number
  default     = 2
  description = "Amount of users to be created for each worker"
}

variable "keyName" {
  type        = string
  description = "Name of your AWS key"
}

variable "keyPath" {
  type        = string
  description = "Full path to your AWS key"
}

variable "atlasPublicApiKey" {
  type        = string
  description = "Atlas Public API key with Project Owner role"
  default = ""
}

variable "atlasPrivateApiKey" {
  type        = string
  description = "Atlas Private API key with Project Owner role"
  default = ""
}

variable "atlasProjectId" {
  type        = string
  description = "Atlas project id which will hold the load test cluster"
  default = ""
}

variable "atlasNumShards" {
  type        = number
  default     = 1
  description = "number of shards to be deployed on Atlas"
}

variable "atlasmajorVersion" {
  type        = string
  description = "Major release of MongoDB to be deployed on Atlas"
  default = ""
}

variable "atlasMSize" {
  type        = string
  description = "Instance size of MongoDB Cluster e.g. 'M30'"
  default = ""
}

variable "diskSizeGb" {
  type        = number
  description = "Disk size of Atlas cluster in GB"
  default     = 100
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

variable "awsVpcId" {
  type        = string
  description = "ID of the VPC on AWS used for the private endpoint and locust nodes"
}

variable "awsSubnetId" {
  type        = string
  description = "ID of the subnet on AWS used for the private endpoint and locust nodes"
}

variable "locustFiles" {
  type        = list(string)
  description = "Locust related files to be copied to locust master and workers"
  default     = ["decimal_codec.py", "load_test.py", "main.py", "mongo_user.py", "settings.py"]
}

variable "locustExecuteFile" {
  type        = string
  description = "Locust file for execution"
  default     = "load_test.py"
}

variable "connectionString" {
  type = string
  description = "Connection String of an existing MongoDB deployment"
  default = ""
}