terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }

    backend "s3" {
        bucket = "tduong10101-terraform-state-bucket"
        key = "tnote_state"
        region = "ap-southeast-2"
    }
}

provider "aws" {
    region = "ap-southeast-2"
}