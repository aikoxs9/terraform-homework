This module sets up a VPC, Subnets, IGW, Route Tables, Security Group, and EC2 Instances using local and input variables.


```hcl
vpc_config = [
  {
    cidr_block     = "10.1.0.0/16"
    dns_support    = true
    dns_hostnames  = true
  }
]

subnet_configs = [
  {
    cidr_block     = "10.1.1.0/24"
    az             = "us-west-2a"
    auto_assign_ip = true
    name           = "public1"
  },
  {
    cidr_block     = "10.1.2.0/24"
    az             = "us-west-2b"
    auto_assign_ip = true
    name           = "public2"
  },
  {
    cidr_block     = "10.1.3.0/24"
    az             = "us-west-2c"
    auto_assign_ip = false
    name           = "private1"
  },
  {
    cidr_block     = "10.1.4.0/24"
    az             = "us-west-2d"
    auto_assign_ip = false
    name           = "private2"
  }
]

igw_name = "homework4_igw"

route_table_names = ["public-rt", "private-rt"]

ports = [22, 80, 443, 3306]

ec2_instances = {
  "public1" = {
    ami           = "ami-0abcdef1234567890"
    instance_type = "t2.micro"
  }
  "public2" = {
    ami           = "ami-0abcdef1234567890"
    instance_type = "t2.micro"
  }
}
