terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
  shared_config_files = ["/Users/asherrankin/.aws/config"]
  shared_credentials_files = ["/Users/asherrankin/.aws/credentials"]
  profile = "root-test"
}
