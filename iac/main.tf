terraform {
  required_version = ">= 0.11.14"

  backend "s3" {
    encrypt     = true
    bucket      = "terraform-remote-state-bp"
    region      = "us-east-1"
    key         = "terraform.tfstate"
  }
}

provider "aws" {
  version                    = ">= 2.6.0"
  skip_requesting_account_id = true
  region                     = "${var.region}"
}

module "vpc" {
  version             = "1.66.0"
  source              = "terraform-aws-modules/vpc/aws"

  name                = "${terraform.workspace}-microservice-bp-vpc"
  cidr                = "${var.vpc_cidr}"

  azs                 = "${var.vpc_zona_disponibilidad}"
  private_subnets     = "${var.vpc_private_subnet}"
  public_subnets      = "${var.vpc_public_subnet}"

  # DNS
  enable_dns_hostnames = true
  enable_dns_support   = true

  # NAT
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = {
    Terraform         = "true"
    Environment       = "dev"
  }
}

resource "aws_key_pair" "microservice_bp" {
  key_name   = "microservice_bp"
  public_key = "${var.ssh_key}"
}

resource "aws_security_group" "sg" {
  name        = "${terraform.workspace}-microservice-bp"
  description = "Permitir SSH"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.sg_cidr_ingress_ssh}"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "microservice-bp" {
  count             = "${var.aws_instance_count}"
  ami               = "${var.aws_instance_ami}"
  instance_type     = "${var.aws_instance_type}"
  availability_zone = "${element(var.vpc_zona_disponibilidad,0)}"
  subnet_id         = "${element(module.vpc.public_subnets,0)}"
  key_name          = "${aws_key_pair.microservice_bp.key_name}"
  security_groups   = ["${aws_security_group.sg.id}"]

  tags = {
    Environment = "${terraform.workspace}"
    Name        = "${terraform.workspace}-microservice-bp"
  }

  depends_on = [
    "aws_security_group.sg"
  ]
}


resource "aws_elb" "microservice-bp-elb" {
  name               = "${terraform.workspace}-microservice-bp-elb"
  subnets           = ["${module.vpc.public_subnets}"]
  security_groups   = ["${aws_security_group.sg.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  instances                   = ["${element(aws_instance.microservice-bp.*.id, 0)}","${element(aws_instance.microservice-bp.*.id, 1)}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "microservice-bp-elb"
  }
}