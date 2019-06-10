# VPC
output "elb_endpoint" {
  description = "ELB Eddpoint"
  value       = "${aws_elb.microservice-bp-elb.dns_name}"
}