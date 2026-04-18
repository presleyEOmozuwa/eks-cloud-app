variable "region" {
    type = string
}

variable "vpc_tags" {
   type = object({
     Name = string
   })
}

variable "public_subnet_tags_1" {
    type = object({
      Name = string
    })
}

variable "public_subnet_tags_2" {
    type = object({
      Name = string
    })
}

variable "igw_tags" {
   type = object({
     Name = string
   })
}

variable "rt_tags" {
   type = object({
     Name = string
   })
}

variable "sg_tags" {
   type = object({
     Name = string
   })
}


variable "ingress_ports" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = 3000, to_port = 3000, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
    { from_port = 5000, to_port = 5000, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
  ]
}

variable "egress_ports" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] },
  ]
}

