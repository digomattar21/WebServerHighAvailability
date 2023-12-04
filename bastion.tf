resource "aws_instance" "bastion" {
  ami                    = "ami-0b61425d47a44fc5f"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.bastion_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id              = aws_subnet.public_1.id

  user_data              = base64encode(file("bastion.sh"))  

  tags = {
    Name = "bastion"
  }
}

resource "aws_eip" "bastion_eip" {
  domain = "vpc"
}

resource "aws_eip_association" "bastion_eip_assoc" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion_eip.id
}

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
