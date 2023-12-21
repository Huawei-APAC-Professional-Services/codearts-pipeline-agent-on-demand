variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  type    = string
  default = "codearts-vpc"
}

variable "ecs_count" {
  type    = number
  default = 1
}

variable "iam_prefix" {
  type    = string
  default = "hfa"
}

variable "accesskey" {
  type = string
}

variable "encryptedsecretkey" {
  type = string
}

variable "codearts_clusterid" {
  type = string
}

variable "codearts_token" {
  type = string
}

variable "codearts_region" {
  type    = string
  default = "ap-southeast-3"
}

variable "download_host" {
  type    = string
  default = "cloud-octopus-agent.obs.cn-north-4.myhuaweicloud.com"
}

variable "terraform_download_url" {
  type    = string
  default = "https://releases.hashicorp.com/terraform/1.6.5/terraform_1.6.5_linux_amd64.zip"
}