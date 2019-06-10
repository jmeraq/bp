variable "region" {
  type        = "string"
  description = "Region AWS"
  default     = "us-east-1"
}


## AWS Instance

variable "aws_instance_type" {
  type        = "string"
  description = "Instance Type"
  default     = "t2.micro"
}

variable "aws_instance_ami" {
  type        = "string"
  description = "Instance ami"
  default     = "ami-03c999cbbc54b7a4d"
}

variable "aws_instance_count" {
  type        = "string"
  description = "Instance Number"
  default     = "2"
}

## SSH Key

variable "ssh_key" {
  type        = "string"
  description = "SSH Key Connection"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLiP2Q1eOmcxGWk26As1X7DXZ+oy1XvBGcyavEhNJR5hzogJfjxKYP8B+3Nn2a5N1fyfKvIu22PkkYW9k4KFcFZ2NzXnFZOYrtiTPaAKOWjteScN3F0IADx1L20CPHlLSHr2ita2no2+BWgZUV1jXDyjBuEET6qznDXVVm1HivZKMS4tXcZU+/asAK5NQMm61ZxyL4JIxbxhbRNtInPkSlUbW0a971hIuOoWMZF9O40txk+H9jmg01yW9pRyAFuH197Y3OD569Qs+U/lTx/nhxsigFd21I/TE5rI0Jtm2mnlr25Y6zG+qnzft7/KMI/YAi2Pq8FUdh+YYGhywveKx5 jmeraq@detic"
}

## VPC
variable "vpc_cidr" {
  type        = "string"
  description = "CIDR Block"
  default     = "11.0.0.0/16"
}

variable "vpc_private_subnet" {
  type        = "list"
  description = "Private Subnet"
  default     = [
    "11.0.1.0/24"
  ]
}

variable "vpc_public_subnet" {
  type        = "list"
  description = "Public Subnet"
  default     = [
    "11.0.2.0/24"
  ]
}

variable "vpc_zona_disponibilidad" {
  type        = "list"
  description = "Zonas de Disponibilidad"
  default     = [
    "us-east-1a"
  ]
}


# Security Group
variable "sg_cidr_ingress_ssh" {
  type        = "list"
  description = "CIDR Block to ingress to instance"
  default     = [
    "181.199.49.142/32"
  ]
}
