#custom vpc varibales
variable "vpc_cidr" {
  description = "value for custom vpc CIDR"
  type        = string
  default     = "10.0.0.0/16"

}

variable "public_subnet_1" {
  description = "value for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2" {
  description = "value for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"

}

variable "private_subnet_1" {
  description = "value for priavte subnet 1"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_2" {
  description = "value for private subnet 2"
  type        = string
  default     = "10.0.4.0/24"

}

variable "az1" {
  description = "value for az1"
  type        = string
  default     = "ap-south-1a"

}

variable "az2" {
  description = "value for az2"
  type        = string
  default     = "ap-south-1b"

}

# ec2 instance ami for Linux
variable "ec2_instance_ami" {
  description = "ec2 instance ami id"
  type        = string
  default     = "ami-0c42696027a8ede58"
}


# ec2 instance type
variable "ec2_instance_type" {
  description = "ec2 instance type"
  type        = string
  default     = "t2.micro"
}