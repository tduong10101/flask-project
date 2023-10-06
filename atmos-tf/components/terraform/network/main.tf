module "vpc" {
    source="github.com/cloudposse/terraform-aws-vpc"

    namespace = "my-vpc"
    stage = "test"

    ipv4_primary_cidr_block = "10.0.0.0/16"

    assign_generated_ipv6_cidr_block = true
}