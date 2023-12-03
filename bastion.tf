resource "aws_instance" "jump_server" {
  ami                    = "ami-0b61425d47a44fc5f"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.js_sg.id]
  subnet_id              = aws_subnet.public_1.id

  user_data              = base64encode(file("bastion.sh"))  

  tags = {
    Name = "bastion"
  }
}

resource "aws_eip" "jump_server_eip" {
  domain = "vpc"
}

resource "aws_eip_association" "jump_server_eip_association" {
  instance_id   = aws_instance.jump_server.id
  allocation_id = aws_eip.jump_server_eip.id
}

resource "aws_security_group_rule" "allow_js_access" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["${aws_eip.jump_server_eip.public_ip}/32"]
  security_group_id = aws_security_group.ec2.id
}

output "jump_server_association" {
  value = aws_eip.jump_server_eip.public_ip
}
