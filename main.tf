################################################################################
# VPC Module
################################################################################
provider "aws" {
  profile = var.profile
  region  = var.main-region
}


module "vpc" {
  source = "./modules/vpc"

  main-region = var.main-region
  profile     = var.profile
}

################################################################################
# EKS Cluster Module
################################################################################

module "eks" {
  source = "./modules/eks-cluster"

  main-region = var.main-region
  profile     = var.profile
  rolearn     = var.rolearn

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}

################################################################################
# AWS ALB Controller
################################################################################

module "aws_alb_controller" {
  source = "./modules/aws-alb-controller"

  main-region  = var.main-region
  env_name     = var.env_name
  cluster_name = var.cluster_name

  vpc_id            = module.vpc.vpc_id
  oidc_provider_arn = module.eks.oidc_provider_arn

  depends_on = [
    module.eks
  ]
}

resource "kubernetes_service" "nginx_service" {
  metadata {
    name = "nginx-service"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal" = "false"
      "service.beta.kubernetes.io/aws-load-balancer-subnets" = join(",", module.vpc.public_subnets)
    }
  }
  spec {
    selector = {
      app = kubernetes_pod.nginx_pod.metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
    type = "LoadBalancer"
    load_balancer_class = "service.k8s.aws/nlb"
  }

  depends_on = [
    module.eks, module.aws_alb_controller
  ]
}

resource "kubernetes_pod" "nginx_pod" {
  metadata {
    name = "nginx-pod"
    labels = {
      app = "nginx"
    }
  }
  spec {
    container {
      image = "public.ecr.aws/k7x7d7j1/masngniximage:latest"
      name  = "nginx"

      port {
        container_port = 80
      }
    }
  }

  depends_on = [
    module.eks
  ]
}

