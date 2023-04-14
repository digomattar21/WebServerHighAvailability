# Configure the AWS provider
provider "aws" {
  region  = "us-east-2"
  profile = "rodry"
}

variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-2"
}


variable "availability_zones" {
  type        = list(string)
  description = "A list of availability zones in the region"
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

resource "aws_key_pair" "example" {
  key_name   = "key_pair_rodry"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Create a new VPC for the infrastructure
resource "aws_vpc" "rodry-vpc-tf" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "rodry-vpc-tf"
  }
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.rodry-vpc-tf.id
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.rodry-vpc-tf.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-4"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.rodry-vpc-tf.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-6"
  }
}

resource "aws_subnet" "private" {
  count                   = 2
  cidr_block              = cidrsubnet("10.0.0.0/16", 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  vpc_id                  = aws_vpc.rodry-vpc-tf.id
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-${count.index}"
  }
}


# Create a Route Table for the public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.rodry-vpc-tf.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  tags = {
    Name = "example-public-rt"
  }
}

# Associate each public subnet with the public Route Table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.rodry-vpc-tf.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Create a new Elastic Load Balancer
resource "aws_lb" "example" {
  name               = "rodry-elb-tf"
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
  security_groups = [aws_security_group.elb.id]

  depends_on = [
    aws_lb_target_group.example
  ]

}

# Create a security group for the Elastic Load Balancer
resource "aws_security_group" "elb" {
  name_prefix = "rodry-sec-elb-tf"
  description = "Security group for the Elastic Load Balancer"
  vpc_id      = aws_vpc.rodry-vpc-tf.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a launch template for the EC2 instances
data "template_file" "user_data" {
  template = file("./server_setup.sh")
}

resource "aws_launch_template" "example" {
  name_prefix            = "rodry-lt-tf"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = aws_key_pair.example.key_name

  user_data = base64encode(data.template_file.user_data.rendered)

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
    }
  }
}

# Create an auto scaling group for the EC2 instances
resource "aws_autoscaling_group" "example" {
  name = "rodry-asg-tf"
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2
  vpc_zone_identifier       = flatten([aws_subnet.public_1.id, aws_subnet.public_2.id])
  health_check_type         = "EC2"
  health_check_grace_period = 300

  target_group_arns = [aws_lb_target_group.example.arn]

  depends_on = [
    aws_launch_template.example,
    aws_lb_target_group.example
  ]
  lifecycle {
    create_before_destroy = true
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  owners = ["099720109477"] # Canonical, the publisher of Ubuntu images
}



# Create a security group for the EC2 instances
resource "aws_security_group" "ec2" {
  name_prefix = "rodry_sec_ec2_tf"
  description = "Security group for the EC2 instances"
  vpc_id      = aws_vpc.rodry-vpc-tf.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.elb.id, aws_security_group.bastion_sg.id]
    description     = "Allow traffic from the load balancer and bastion"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH traffic from bastion"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "target-group-sg"
  }
}


resource "aws_lb_target_group" "example" {
  name_prefix = "rodry"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.rodry-vpc-tf.id

  health_check {
    path                = "/index.html"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

}


resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = aws_autoscaling_group.example.name
  lb_target_group_arn    = aws_lb_target_group.example.arn
}

resource "aws_autoscaling_attachment" "example_2" {
  autoscaling_group_name = aws_autoscaling_group.example.name
  lb_target_group_arn    = aws_lb_target_group.example.arn
}

resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

resource "aws_lb_listener_rule" "example" {
  listener_arn = aws_lb_listener.example.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }

  condition {
    host_header {
      values = [aws_lb.example.dns_name]
    }
  }
}

# Configure CloudWatch to monitor the EC2 instances
resource "aws_cloudwatch_metric_alarm" "example" {
  alarm_name          = "rodry-cw-tf"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "93"
  alarm_description   = "This metric monitors the CPU utilization of the EC2 instances."
  alarm_actions       = ["arn:aws:sns:us-east-2:746108472597:my-cloudwatch-sns-topic"]
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.example.name}"
  }
}

# Configure GuardDuty to monitor the AWS account
# Create a GuardDuty detector
# resource "aws_guardduty_detector" "example" {
#   enable = true
# }

# resource "null_resource" "generate_ipset_file" {
#   provisioner "local-exec" {
#     command = <<EOT
#       SECURITY_GROUP_ID="${aws_security_group.ec2.id}"
#       OUTPUT_FILE="ipset-file.txt"

#       aws ec2 describe-instances \
#         --filters "Name=instance.group-id,Values=$SECURITY_GROUP_ID" \
#         --query 'Reservations[*].Instances[*].PrivateIpAddress' \
#         --output text | tr '\t' '\n' > "$OUTPUT_FILE"
# EOT
#   }
# }

# resource "aws_s3_bucket" "asg_ips_bucket" {
#   bucket = "rodry-bucket-guardduty-ips"
#   acl    = "private"
# }

# resource "aws_s3_bucket_object" "asg_ips_file" {
#   depends_on = [null_resource.generate_ipset_file]

#   bucket = aws_s3_bucket.asg_ips_bucket.id
#   key    = "rodry-asg-ips.txt"
#   source = "ipset-file.txt"
#   acl    = "private"
# }

# # Create a threat intelligence list with the IP addresses of your Auto Scaling group instances
# resource "aws_guardduty_threatintelset" "asg_threatintelset" {
#   name        = "asg-threatintelset"
#   activate    = true
#   format      = "TXT"
#   location    = "s3://${aws_s3_bucket.asg_ips_bucket.bucket}/asg-ips.txt"
#   detector_id = aws_guardduty_detector.example.id
# }

# # Create an IP match condition for the threat intelligence list
# resource "aws_guardduty_ipset" "asg_ipmatchset" {
#   name        = "asg-ipmatchset"
#   format      = "TXT"
#   activate    = true
#   location    = aws_guardduty_threatintelset.asg_threatintelset.location
#   detector_id = aws_guardduty_detector.example.id
# }




# Output the Elastic Load Balancer's DNS name
output "elb_dns_name" {
  value = aws_lb.example.dns_name
}

output "target_group_name" {
  value = aws_lb_target_group.example.name
}


# BASTION CONFIG

# Create a security group for the bastion host
resource "aws_security_group" "bastion_sg" {
  name_prefix = "bastion-sg-"
  vpc_id      = aws_vpc.rodry-vpc-tf.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a key pair for the bastion host
resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Create a bastion host with a public IP address
resource "aws_instance" "bastion" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.bastion_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id              = aws_subnet.public_1.id

  tags = {
    Name = "bastion"
  }

  # Create an elastic IP address for the bastion host
  provisioner "local-exec" {
    command = "aws ec2 associate-address --instance-id ${aws_instance.bastion.id} --public-ip ${aws_eip.bastion_eip.public_ip}"
  }
}

# Create an elastic IP address for the bastion host
resource "aws_eip" "bastion_eip" {
  vpc = true
}

# Update the security groups for your instances to allow access from the bastion host
resource "aws_security_group_rule" "allow_bastion_access" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["${aws_eip.bastion_eip.public_ip}/32"]
  security_group_id = aws_security_group.ec2.id
}

output "bastion_public_ip" {
  value = aws_eip.bastion_eip.public_ip
}
