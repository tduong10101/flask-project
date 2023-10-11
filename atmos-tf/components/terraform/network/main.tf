module "vpc" {
    source="github.com/cloudposse/terraform-aws-vpc"

    namespace = "my-vpc"
    stage = "test"

    ipv4_primary_cidr_block = var.ipv4_cidr

    assign_generated_ipv6_cidr_block = true
}