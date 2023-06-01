provider "aws" {
  region = "us-east-2"
}

variable "subnet_cidr_block" {}
variable "vpc_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "my_IP" {}
variable "PRIVKEY_PATH" {}
variable "instance_type_1" {}
variable "instance_type_2" {}
variable "instance_type_3" {}
variable "ssh_key_private" {}


# vpc  creation

resource "aws_vpc" "development-vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

# subnet creation

resource "aws_subnet" "dev-sub-1" {
  vpc_id            = aws_vpc.development-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone

  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }

}

# Internet Gateway 

resource "aws_internet_gateway" "my-app-gw" {
  vpc_id = aws_vpc.development-vpc.id

  tags = {
    Name = "${var.env_prefix}-gw"
  }
}

# Route Table

resource "aws_route_table" "myapp-RT" {
  vpc_id = aws_vpc.development-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-app-gw.id
  }

  tags = {
    Name = "${var.env_prefix}-RT"
  }
}

# Route table subnet Association

resource "aws_route_table_association" "sub-asso" {
  subnet_id      = aws_subnet.dev-sub-1.id
  route_table_id = aws_route_table.myapp-RT.id
}

# security group creation

resource "aws_security_group" "my-app-sg" {
  name        = "my-app-sg"
  description = "Allow TLS inbound traffic for my servers"
  vpc_id      = aws_vpc.development-vpc.id

  ingress {
    description = "Allow from my local machine"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_IP]

  }

  ingress {
    description = "TLS from VPC"
    from_port   = 8080
    to_port     = 8080
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
    Name = "my-app_SG"
  }
}


# instance creation

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]

  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}


resource "aws_instance" "my-app-webserver-1" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type_1
  key_name      = "my-key-1"

  subnet_id              = aws_subnet.dev-sub-1.id
  vpc_security_group_ids = [aws_security_group.my-app-sg.id]
  availability_zone      = var.avail_zone

  associate_public_ip_address = true


  tags = {
    Name = "web-server-app1"

  }
}

resource "aws_instance" "my-app-webserver-2" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type_2
  key_name      = "my-key-1"

  subnet_id              = aws_subnet.dev-sub-1.id
  vpc_security_group_ids = [aws_security_group.my-app-sg.id]
  availability_zone      = var.avail_zone

  associate_public_ip_address = true


  tags = {
    Name = "web-server-app2"
  }


}

resource "aws_instance" "my-app-webserver-3" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type_3
  key_name      = "my-key-1"

  subnet_id              = aws_subnet.dev-sub-1.id
  vpc_security_group_ids = [aws_security_group.my-app-sg.id]
  availability_zone      = var.avail_zone

  associate_public_ip_address = true


  tags = {
    Name = "web-server-app3"
  }


}

output "server-ip_1" {
  value = aws_instance.my-app-webserver-1.public_ip
}
output "server-ip_2" {
  value = aws_instance.my-app-webserver-2.public_ip
}
output "server-ip_3" {
  value = aws_instance.my-app-webserver-3.public_ip
}

output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id

}