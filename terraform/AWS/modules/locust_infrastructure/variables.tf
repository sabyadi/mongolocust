variable "region" {
  type        = string
  description = "AWS Region"
}

variable "locustMasterInstanceType" {
  type        = string
  description = "AWS Instance Type of the locust primary"
  default     = "t2.small"
}

variable "locustWorkerInstanceType" {
  type        = string
  description = "AWS Instance Type of the locust workers"
  default     = "t2.small"
}

variable "workernodeCount" {
  type        = number
  description = "amount of worker nodes to be deployed"
  default     = 1
}

variable "keyName" {
  type        = string
  description = "Name of your AWS key"
}

variable "keyPath" {
  type        = string
  description = "Full path to your AWS key"
}


variable "awsSubnetId" {
  type        = string
  description = "ID of the subnet on AWS used for the private endpoint and locust nodes"
}
