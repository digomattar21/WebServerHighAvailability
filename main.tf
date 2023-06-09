resource "aws_vpc" "rodry-vpc-tf" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "rodry-vpc-tf"
  }
}

output "elb_dns_name" {
  value = aws_lb.example.dns_name
}

output "target_group_name" {
  value = aws_lb_target_group.example.name
}
