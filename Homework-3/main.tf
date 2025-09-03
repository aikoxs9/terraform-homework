provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "kaizen" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "kaizen"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.kaizen.id
  tags = {
    Name = "homework3_igw"
  }
}


resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.kaizen.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.kaizen.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public2"
  }
}


resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.kaizen.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2c"
  tags = {
    Name = "private1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.kaizen.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-west-2d"
  tags = {
    Name = "private2"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.kaizen.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.kaizen.id

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private_rt.id
}


resource "aws_security_group" "homework3_sg" {
  name        = "homework3_sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.kaizen.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "homework3_sg"
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] 

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "ubuntu" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public1.id
  vpc_security_group_ids = [aws_security_group.homework3_sg.id]
  associate_public_ip_address = true
  key_name               = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y apache2
              systemctl enable apache2
              systemctl start apache2
              EOF

  tags = {
    Name = "Ubuntu"
  }
}


data "aws_ami" "amazon" {
  most_recent = true
  owners      = ["137112412989"] 

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "amazon" {
  ami                    = data.aws_ami.amazon.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public2.id
  vpc_security_group_ids = [aws_security_group.homework3_sg.id]
  associate_public_ip_address = true
  key_name               = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              systemctl enable httpd
              systemctl start httpd
              EOF

  tags = {
    Name = "Amazon"
  }
}
