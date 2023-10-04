provider "aws" {
  region = ap-south-1
}

#VPC Block
resource "aws_vpc" "custom_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    name = "custom_vpc"
  }
}

#public subnet
resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.custom_vpc.id
  cidr_block = var.public_subnet_1
  availability_zone = var.az1
  tags = {
    name = "public_subnet_1"
    }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.custom_vpc.id
  cidr_block = var.public_subnet_2
  availability_zone = var.az2
  tags = {
    name = "public_subnet_2"
  }
  
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.custom_vpc.id
  cidr_block = var.private_subnet_1
  availability_zone = var.az1
  tags = {
    name = "private_subnet_1"
  }
  
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.custom_vpc.id
  cidr_block = var.private_subnet_2
  availability_zone = var.az2
  tags = {
    name = "private_subnet_2"
  }
  
}

#creating IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    name = "igw"
  }
  
}

#routing table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.custom_vpc.id
  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id  = aws_internet_gateway.igw.id
  } 
    tags = {
      name = "rt"
    }
  
}
#associate route table to the public subnet 1
resource "aws_route_table_association" "public_rt1" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_subnet.public_subnet_1.id
  
}

resource "aws_route_table_association" "public_rt2" {
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_subnet.public_subnet_2.id

}
resource "aws_route_table_association" "private_rt1" {
  subnet_id = aws_subnet.private_subnet_1.id
  route_table_id = aws_subnet.private_subnet_1.id
  
}

resource "aws_route_table_association" "private_rt2" {
  subnet_id = aws_subnet.private_subnet_2.id
  route_table_id = aws_subnet.private_subnet_2.id
  
}