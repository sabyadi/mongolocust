terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.61"
    }
  }

  required_version = ">= 1.0.8"
}

resource "aws_security_group" "Locust_Firewall" {
  name        = "LocustNodes_rule"
  description = "Allow ingress for locust"

  ingress = [
    {
      description      = "SSH Traffic"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    },
    {
      description      = "Locust Traffic"
      from_port        = 8089
      to_port          = 8089
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    },
    {
      description      = "Locust Traffic"
      from_port        = 5557
      to_port          = 5557
      protocol         = "tcp"
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

data "aws_ami" "AWSlinux2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20210721.2-x86_64-gp2"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "locust_main" {
  ami                    = data.aws_ami.AWSlinux2.id
  instance_type          = var.locustMasterInstanceType
  vpc_security_group_ids = [aws_security_group.Locust_Firewall.id]
  key_name               = var.keyName
  subnet_id              = var.awsSubnetId
  tags = {
    Name      = "locustMaster"
  }
}

resource "aws_instance" "locust_worker" {
  count                  = var.workernodeCount
  ami                    = data.aws_ami.AWSlinux2.id
  instance_type          = var.locustWorkerInstanceType
  vpc_security_group_ids = [aws_security_group.Locust_Firewall.id]
  key_name               = var.keyName
  subnet_id              = var.awsSubnetId

  tags = {
    Name      = "locust_worker",
  }  
}

output "master_public_dns" {
  description = "Locust master public dns"
  value       = aws_instance.locust_main.public_dns
}

output "workerNodes_public_dns" {
  description = "List of locust worker public dns"
  value       = aws_instance.locust_worker[*].public_dns
}
