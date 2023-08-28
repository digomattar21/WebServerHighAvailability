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

resource "aws_lb_target_group" "example" {
  name_prefix = "rodry"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.rodry-vpc-tf.id

  health_check {
    enabled             = true
    interval            = 120
    path                = "/todos"
    timeout             = 119
    healthy_threshold   = 3
    unhealthy_threshold = 10
    protocol            = "HTTP"
    matcher             = "200"
  }

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
