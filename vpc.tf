provider "aws" {
  region                  = var.region
  access_key              = var.access_key
  secret_key              = var.secret_key
}


resource "aws_vpc" "my-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "my-subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch  = "true"

  tags = {
    Name = "my-subnet"
  }
}

resource "aws_eip" "elastic-ip" {
  vpc      = true
}

resource "aws_nat_gateway" "My-NAT" {
  allocation_id = aws_eip.elastic-ip.id
  subnet_id     = aws_subnet.my-subnet.id

  tags = {
    Name = "My-NAT"
  }
}

resource "aws_internet_gateway" "my-IG" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "my-IG"
  }
}

resource "aws_route_table" "my-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.my-IG.id
  }

  tags = {
    Name = "route-table"
  }
}

resource "aws_route_table_association" "associate" {
  subnet_id      = aws_subnet.my-subnet.id
  route_table_id = aws_route_table.my-rt.id
}
