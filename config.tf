provider "aws" {
  region  = "us-east-2"
}

variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-2"
}


variable "availability_zones" {
  type        = list(string)
  description = "A list of availability zones in the region"
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}
