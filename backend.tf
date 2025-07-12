terraform {
  cloud {
    organization = "tsuguchi"

    workspaces {
      name = "tsuguchi-workspace"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}



