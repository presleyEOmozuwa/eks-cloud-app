
// resource 1
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags                 = var.vpc_tags
}

resource "aws_subnet" "public" {
  count = 2

  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.${count.index + 1}.0/24"
  map_public_ip_on_launch = true
  availability_zone = ["us-east-1a", "us-east-1b"][count.index]

  tags = {
    Name = "public-${count.index}"
  }
}


// resource 3
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = var.igw_tags
}

// resource 4
resource "aws_route_table" "routetable" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = var.rt_tags
}

// resource 5
resource "aws_route_table_association" "rta_1" {
  subnet_id = aws_subnet.public[0].id
  route_table_id = aws_route_table.routetable.id
}

resource "aws_route_table_association" "rta_2" {
  subnet_id = aws_subnet.public[1].id
  route_table_id = aws_route_table.routetable.id
}

// resource 6
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.egress_ports
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
  tags = var.sg_tags

}
















