data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
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

  owners = ["099720109477"] 
}


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

resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = aws_autoscaling_group.example.name
  lb_target_group_arn    = aws_lb_target_group.example.arn
}

resource "aws_autoscaling_attachment" "example_2" {
  autoscaling_group_name = aws_autoscaling_group.example.name
  lb_target_group_arn    = aws_lb_target_group.example.arn
}
