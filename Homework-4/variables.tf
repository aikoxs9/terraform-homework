variable "vpc_config" {
  type = list(object({
    cidr_block     = string
    dns_support    = bool
    dns_hostnames  = bool
  }))
}

variable "subnet_configs" {
  type = list(object({
    cidr_block     = string
    az             = string
    auto_assign_ip = bool
    name           = string
  }))
}

variable "igw_name" {
  type = string
}

variable "route_table_names" {
  type = list(string)
}

variable "ports" {
  type = list(number)
}

variable "ec2_instances" {
  type = map(object({
    ami           = string
    instance_type = string
  }))
}
