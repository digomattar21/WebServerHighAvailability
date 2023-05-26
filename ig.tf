resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.rodry-vpc-tf.id
}
