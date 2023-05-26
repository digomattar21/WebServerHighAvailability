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
