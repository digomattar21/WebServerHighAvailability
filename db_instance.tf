resource "aws_instance" "postgres_db" {
  ami                    = "ami-0b61425d47a44fc5f"  
  instance_type          = "t2.micro"               
  key_name               = aws_key_pair.example.key_name  
  vpc_security_group_ids = [aws_security_group.postgres_db_sg.id]
  subnet_id              = aws_subnet.private[0].id
  user_data = base64encode(file("postgres.sh"))  

  tags = {
    Name = "PostgresDB"
  }
}

