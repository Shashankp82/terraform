provider "aws" {
  region = "ap-south-1"
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
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = var.public_subnet_1
  availability_zone = var.az1
  tags = {
    name = "public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = var.public_subnet_2
  availability_zone = var.az2
  tags = {
    name = "public_subnet_2"
  }

}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = var.private_subnet_1
  availability_zone = var.az1
  tags = {
    name = "private_subnet_1"
  }

}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = var.private_subnet_2
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
   route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
      name = "rt"
  }
}


#associate route table to the public subnet 1
resource "aws_route_table_association" "public_rt1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_subnet.public_subnet_1.id

}

resource "aws_route_table_association" "public_rt2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_subnet.public_subnet_2.id

}
resource "aws_route_table_association" "private_rt1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_subnet.private_subnet_1.id

}

resource "aws_route_table_association" "private_rt2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_subnet.private_subnet_2.id

}

#Security group for web,db
# custom vpc security group 
resource "aws_security_group" "web_sg" {
   name        = "web_sg"
   description = "allow inbound HTTP traffic"
   vpc_id      = aws_vpc.custom_vpc.id

   # HTTP from vpc
   ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]     
   }


  # outbound rules
  # internet access to anywhere
  egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
     name = "web_sg"
  }
}


# web tier security group
resource "aws_security_group" "webserver_sg" {
  name        = "webserver_sg"
  description = "allow inbound traffic from ALB"
  vpc_id      = aws_vpc.custom_vpc.id
  
  # allow inbound traffic from web
  ingress {
     from_port       = 80
     to_port         = 80
     protocol        = "tcp"
     security_groups = [aws_security_group.web_sg.id]
  }

  egress {
     from_port = "0"
     to_port   = "0"
     protocol  = "-1"
     cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
     name = "webserver_sg"
  }
}


#INSTANCES BLOCK - EC2
#1st ec2 instance on public subnet 1
resource "aws_instance" "ec2_1" {
  ami                    = var.ec2_instance_ami
  instance_type          = var.ec2_instance_type
  availability_zone      = var.az1
  subnet_id              = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  user_data              = <<EOF
  #!/bin/bash
       yum update -y
       yum install -y httpd
       systemctl start httpd
       systemctl enable httpd
       EC2AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
       echo '<center><h1>This Amazon EC2 instance is located in Availability Zone:AZID </h1></center>' > /var/www/html/index.txt
       sed"s/AZID/$EC2AZ/" /var/www/html/index.txt > /var/www/html/index.html
       EOF
  tags = {
    name = "ec2_1"
  }
}

# 2nd ec2 instance on public subnet 2
resource "aws_instance" "ec2_2" {
  ami                    = var.ec2_instance_ami
  instance_type          = var.ec2_instance_type
  availability_zone      = var.az2
  subnet_id              = aws_subnet.public_subnet_2.id
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  user_data              = <<EOF
       #!/bin/bash
       yum update -y
       yum install -y httpd
       systemctl start httpd
       systemctl enable httpd
       EC2AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
       echo '<center><h1>This Amazon EC2 instance is located in Availability Zone:AZID </h1></center>' > /var/www/html/index.txt
       sed"s/AZID/$EC2AZ/" /var/www/html/index.txt > /var/www/html/index.html
       EOF 

  tags = {
    name = "ec2_2"
  }
}