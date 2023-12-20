locals {
  agent_subnet_cidr = cidrsubnet(var.vpc_cidr, 4, 0)
}

resource "huaweicloud_vpc" "agent_vpc" {
  name = var.vpc_name
  cidr = var.vpc_cidr
}

resource "huaweicloud_vpc_subnet" "agent_subnet" {
  name       = "agent_subnet"
  cidr       = local.agent_subnet_cidr
  gateway_ip = cidrhost(local.agent_subnet_cidr, 1)
  vpc_id     = huaweicloud_vpc.agent_vpc.id
}

data "huaweicloud_availability_zones" "main" {}

data "template_file" "init" {
  template = file("${path.module}/ecs_init.yaml")
  vars = {
    ak                     = var.accesskey
    sk                     = var.encryptedsecretkey
    cluster_id             = var.codearts_clusterid
    project_id             = var.codearts_token
    region                 = var.codearts_region
    download_host          = var.download_host
    terraform_download_url = var.terraform_download_url
  }
}

resource "random_string" "iam_suffix" {
  length  = 8
  special = false
  numeric = false
}

resource "huaweicloud_identity_role" "assume_role" {
  name = "${var.iam_prefix}-${random_string.iam_suffix.id}"
  type = "AX"
  policy = jsonencode({
    "Version" : "1.1",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:agencies:assume"
        ]
      }
    ]
  })
  description = "Allowing Assume Role"
}

resource "huaweicloud_identity_agency" "ecs_root" {
  name                   = "${var.iam_prefix}-${random_string.iam_suffix.id}"
  description            = "Manage resources in HFA"
  delegated_service_name = "op_svc_ecs"

  all_resources_roles = [
    huaweicloud_identity_role.assume_role.name
  ]
}

module "agent" {
  count             = var.ecs_count
  source            = "github.com/Huawei-APAC-Professional-Services/terraform-module/public-ecs"
  availability_zone = data.huaweicloud_availability_zones.main.names[0]
  instance_name     = var.instance_name
  subnet_id         = huaweicloud_vpc_subnet.agent_subnet.id
  user_data         = data.template_file.init.rendered
  agency_name       = huaweicloud_identity_agency.ecs_root.name
}