terraform {
  cloud {
    organization = "fiap-postech-soat1-group21"
    workspaces {
      name = "restaurant"
    }
  }
}

provider "aws" {
  region     = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}

data "terraform_remote_state" "restaurant_database" {
  backend = "remote"

  config = {
    organization = "fiap-postech-soat1-group21"
    workspaces = {
      name = "restaurant-database"
    }
  }
}