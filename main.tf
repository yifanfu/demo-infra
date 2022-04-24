provider "aws" {}

terraform {
  backend "s3" {
    bucket = "yifanfu"
    key    = "ephemeral-state"
  }
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  name = "ephrmeral-cluster"

  container_insights = true

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
    }
  ]

  tags = {
    Environment = var.Environment
  }
}


module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name = "ephrmeral-alb"

  load_balancer_type = "application"

  vpc_id          = "vpc-fe62799b"
  security_groups = ["sg-e1a58b85"]
  subnets         = ["subnet-3c15b358","subnet-0c40d4c2ee63eab0d"]

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = []
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
}

resource "aws_ssm_parameter" "ephemeral_cluster_name" {
  name = "/yifanfu/ephemeral/cluster-name"
  type = "String"
  value = module.ecs.ecs_cluster_name
}

resource "aws_ssm_parameter" "ephemeral_listener_arn" {
  name = "/yifanfu/ephemeral/listener-arn"
  type = "String"
  value = module.alb.http_tcp_listener_arns[0]
}

resource "aws_ssm_parameter" "ephemeral_alb_dns_name" {
  name = "/yifanfu/ephemeral/alb-dns-name"
  type = "String"
  value = module.alb.lb_dns_name
}

resource "aws_ssm_parameter" "ephemeral_alb_zone_id" {
  name = "/yifanfu/ephemeral/alb-zone-id"
  type = "String"
  value = module.alb.lb_zone_id
}
