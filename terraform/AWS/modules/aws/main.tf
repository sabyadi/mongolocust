terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.61"
    }
  }
  required_version = ">= 1.0.8"
}

resource "aws_security_group" "Locust_enpoint_Firewall" {
  name        = "locust_enpoint_rule"
  description = "Allow ingress for locust"

  ingress = [
    {
      description      = "Private Endpoint Traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]
  egress = [
    {
      description      = "All Ports/Protocols"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]
}


resource "aws_vpc_endpoint" "aws_endpoint_service" {
  vpc_id             = var.vpcId
  service_name       = var.atlasServiceName
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [var.subnetId]
  security_group_ids = [aws_security_group.Locust_enpoint_Firewall.id]
}

output "endpoint_service_id" {
  value       = aws_vpc_endpoint.aws_endpoint_service.id
  description = "Id of endpoint service on AWS"
}
