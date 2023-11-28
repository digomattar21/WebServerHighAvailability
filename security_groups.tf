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

resource "aws_security_group" "ec2" {
  name_prefix = "rodry_sec_ec2_tf"
  description = "Security group for the EC2 instances"
  vpc_id      = aws_vpc.rodry-vpc-tf.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.elb.id, aws_security_group.bastion_sg.id]
    description     = "Allow traffic from the load balancer and bastion"
  }

  ingress {
    from_port       = 9229
    to_port         = 9229
    protocol        = "tcp"
    security_groups = [aws_security_group.elb.id, aws_security_group.bastion_sg.id]
    description     = "Allow traffic from the load balancer and bastion"
  }

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

resource "aws_security_group" "rds" {
  name_prefix = "rodry_sec_redis"
  description = "Security group for the RDS instances"
  vpc_id      = aws_vpc.rodry-vpc-tf.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
    description     = "Allow traffic from the ec2s to RDS"
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

resource "aws_security_group" "redis" {
  name_prefix = "rodry_sec_redis"
  description = "Security group for the Redis instances"
  vpc_id      = aws_vpc.rodry-vpc-tf.id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
    description     = "Allow traffic from the ec2s to redis"
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

