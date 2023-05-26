resource "aws_instance" "bastion" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.bastion_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id              = aws_subnet.public_1.id

  tags = {
    Name = "bastion"
  }

  provisioner "local-exec" {
    command = "aws ec2 associate-address --instance-id ${aws_instance.bastion.id} --public-ip ${aws_eip.bastion_eip.public_ip}"
  }
}

resource "aws_eip" "bastion_eip" {
  vpc = true
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
