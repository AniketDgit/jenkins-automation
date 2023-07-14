terraform {
  backend "s3" {
    bucket         = "cicd-automation"
    key            = "eks/terraform.tfstate"
    region         = "ap-south-1"
  }
}
