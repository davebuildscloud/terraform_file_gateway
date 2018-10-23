#Optional Parameters

variable "ebs_cache_volume_size" {
  description = "The size, in GB, for the cache volume associated with this file gateway"
  default     = 150
}

variable "instance_type" {
  description = "The type of EC2 instance to launch.  Consult the AWS Storage Gateway documentation for supported instance types"
  default     = "m4.xlarge"
}

variable "client_access_list" {
  type        = "list"
  description = "The list of client IPs or CIDR blocks that can access the gateway"
  default     = ["0.0.0.0/0"]
}

#Required Parameters

variable "vpc_id" {
  description = "The ID of the VPC into which the gateway is deployed"
}

variable "subnet_id" {
  description = "The ID of the subnet into which your gateway should be deployed"
}

variable "key_name" {
  description = "The AWS key to be used during the creation of this instance"
}

variable "gateway_name" {
  description = "The friendly name to assign to the storage gateway"
}

variable "gateway_time_zone" {
  description = "The time zone the gateway should use.  Entered in the format GMT-6:00"
}

variable "bucket_name" {
  description = "The name to give your S3 bucket"
}

variable "bucket_region" {
  description = "The region in whcih to create your s3 bucket"
}

variable "deployment_cidr" {
  description = "The CIDR block for the IP range from which your hosts will deploy and configure the gateway"
}

variable "zone_name" {
  description = "The DNS Zone into which the record for your gateway should be created"
}
