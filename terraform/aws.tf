terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.2.0"
    }
  }
}

variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "SSH_KEY" {}
variable "SSH_IP" {}

variable "instance_count" {
  description = "Number of EC2 instances in each private subnet"
  type        = number
  default     = 1
}


provider "aws" {
  region = "eu-west-3"
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.SSH_KEY
}

resource "aws_default_security_group" "ssh_kubernetes" {
  vpc_id      = aws_vpc.vpc_linuxfondation.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.SSH_IP]
  }
  ingress {
    description      = "Kubeadm port"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.SSH_IP, "10.42.0.0/24"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_internet_gateway" "net_gateway" {
  vpc_id = aws_vpc.vpc_linuxfondation.id

  tags = {
    Name = "linuxfondation"
  }
}
resource "aws_default_route_table" "route_linuxfondation" {
	default_route_table_id = aws_vpc.vpc_linuxfondation.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.net_gateway.id
  }
}

resource "aws_vpc" "vpc_linuxfondation" {
  cidr_block = "10.42.0.0/16"
	enable_dns_hostnames = true
	tags = {
		name = "vpc_linuxfondation"
	}
}

resource "aws_subnet" "subnet_linuxfondation" {
  vpc_id            = aws_vpc.vpc_linuxfondation.id
  cidr_block        = "10.42.0.0/24"
  availability_zone = "eu-west-3c"
	map_public_ip_on_launch = true
}

resource "aws_network_interface" "workers_net" {
  count = var.instance_count

  subnet_id = aws_subnet.subnet_linuxfondation.id
}
resource "aws_network_interface" "cp_net" {
  subnet_id = aws_subnet.subnet_linuxfondation.id
}

resource "aws_instance" "cp" {
  ami           = "ami-03b0b8a211c9e0101"
  instance_type = "t3.small"
	key_name      = aws_key_pair.deployer.key_name

	network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.cp_net.id
  }
  tags = {
    Name = "linuxfondation_cp"
  }
}
resource "aws_instance" "workers" {
  count = var.instance_count

  ami           = "ami-03b0b8a211c9e0101"
  instance_type = "t3.small"
	key_name      = aws_key_pair.deployer.key_name

	network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.workers_net[count.index].id
  }
  tags = {
    Name = "linuxfondation_wokers_${count.index + 1}"
  }
}

output "instance_public_ips" {
  value = [aws_instance.cp.*.public_ip, aws_instance.workers.*.public_ip]
}

resource "local_file" "public_ips" {
  content  = "[cp]\n${aws_instance.cp.public_ip}\n[workers]\n${join("\n", aws_instance.workers[*].public_ip)}"
  filename = "../ansible/ansible_hosts"
}