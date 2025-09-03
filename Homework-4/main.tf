provider "aws" {
  region = "us-west-2"
}


locals {
  common_tags = {
    Name        = "Kaizen"
    Environment = "Dev"
    Department  = "Engineering"
    Team        = "DevOps"
    CreatedBy   = "manual"
    Owner       = "Your Name"
    Project     = "E-commerce"
    Application = "Wordpress"
  }
}


resource "aws_vpc" "kaizen" {
  cidr_block           = var.vpc_config[0].cidr_block
  enable_dns_support   = var.vpc_config[0].dns_support
  enable_dns_hostnames = var.vpc_config[0].dns_hostnames

  tags = local.common_tags
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.kaizen.id

  tags = merge(local.common_tags, {
    Name = var.igw_name
  })
}


resource "aws_subnet" "subnets" {
  for_each = { for idx, subnet in var.subnet_configs : subnet.name => subnet }

  vpc_id                  = aws_vpc.kaizen.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.auto_assign_ip

  tags = merge(local.common_tags, {
    Name = each.value.name
  })
}

# Route Tables
resource "aws_route_table" "route_tables" {
  for_each = toset(var.route_table_names)

  vpc_id = aws_vpc.kaizen.id

  tags = merge(local.common_tags, {
    Name = each.value
  })
}


resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.route_tables["public-rt"].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}


resource "aws_route_table_association" "rt_association" {
  for_each = {
    "public1"  = "public-rt",
    "public2"  = "public-rt",
    "private1" = "private-rt",
    "private2" = "private-rt"
  }

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.route_tables[each.value].id
}

resource "aws_security_group" "sg" {
  name        = "homework4_sg"
  description = "Security Group for Homework4"
  vpc_id      = aws_vpc.kaizen.id

  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}


resource "aws_key_pair" "key" {
  key_name   = "homework4-key"
  public_key = file("~/.ssh/homework4-key.pub")

  tags = local.common_tags
}


resource "aws_instance" "ec2" {
  for_each = var.ec2_instances

  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  subnet_id                   = aws_subnet.subnets[each.key].id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key.key_name

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y || sudo apt update -y
              sudo yum install -y httpd || sudo apt install -y apache2
              sudo systemctl enable httpd || sudo systemctl enable apache2
              sudo systemctl start httpd || sudo systemctl start apache2
              EOF

  tags = merge(local.common_tags, {
    Name = each.key
  })
}
