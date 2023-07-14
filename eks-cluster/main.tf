data "aws_availability_zones" "azs" {}
module "jenkins-server-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-server-vpc"
  cidr = var.vpc_cidr_block

  azs             = data.aws_availability_zone.azs.names
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets  = var.public_subnet_cidr_blocks

  enable_dns_hostname = true

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    "kubernetes.io/cluster/jenkins-server-eks-cluster" = "shared"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/jenkins-server-eks-cluster" = "shared"
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/jenkins-server-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }

}

module "eks" {
    source = "terraform-aws-module/eks/aws"
    version = "~> 19.0"
    cluster_name = "jenkins-server-eks-cluster"
    cluster_version = "1.24"
    cluster_endpoint_public_access  = true
    vpc_id = module.jenkins-server-vpc.id
    subnet_ids = module.jenkins-server-vpc.private_subnets
    tags = {
        environment = "development"
        application = "myjenkins-server"
    }    

    eks_managed_node_groups = {
        dev = {
            min_size = 1
            max_size = 3
            desired_size = 2
            instance_type = ["t2.small"]
        }
    }
}
