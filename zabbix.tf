# Zabbix Instance Configuration
resource "aws_instance" "zabbix" {
  ami                    = "ami-0b61425d47a44fc5f"  # us-east-2 jammy amd64
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.example.key_name
  vpc_security_group_ids = [aws_security_group.zabbix_sg.id]
  subnet_id              = aws_subnet.public_1.id
  user_data              = base64encode(file("zabbix.sh"))    

  tags = {
    Name = "Zabbix"
  }
}

# Zabbix Security Group
resource "aws_security_group" "zabbix_sg" {
  vpc_id = aws_vpc.rodry-vpc-tf.id  

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port = 0
    protocol = "-1"
    security_groups = [ aws_security_group.ec2.id, aws_security_group.postgres_db_sg.id  ]  
    description = "Allow all inbound traffic from EC2 and Postgres DB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow SSH access from Bastion
resource "aws_security_group_rule" "allow_ssh_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
  security_group_id        = aws_security_group.zabbix_sg.id
}

# Elastic IP for Zabbix Instance
resource "aws_eip" "zabbix_eip" {
  domain = "vpc"
}

# Associate Elastic IP with Zabbix Instance
resource "aws_eip_association" "zabbix_eip_assoc" {
  instance_id   = aws_instance.zabbix.id
  allocation_id = aws_eip.zabbix_eip.id
}

# Output Zabbix EIP Address
output "zabbix_eip_address" {
  value = aws_eip.zabbix_eip.public_ip
}
