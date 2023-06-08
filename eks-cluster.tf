module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.13.1"

  cluster_name                   = "myapp-eks-cluster"
  cluster_version                = "1.26"
  cluster_endpoint_public_access = true

  subnet_ids = [aws_subnet.dev-sub-1.id, aws_subnet.dev-sub-2.id]
  vpc_id     = aws_vpc.development-vpc.id


  tags = {
    environment = "development"
    application = "myapp"
  }


  eks_managed_node_groups = {

    dev = {
      min_size     = 1
      max_size     = 3
      desired_size = 3

      instance_types = ["t3.small"]

    }
  }
}