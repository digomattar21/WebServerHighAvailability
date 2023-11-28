# RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id]

  tags = {
    Name = "RDS Subnet Group"
  }
}

# RDS Instance for PostgreSQL
resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "15.3"
  instance_class       = "db.t3.micro" 
  identifier           = "pago"
  username             = "postgres"
  password             = "postgres"
  parameter_group_name = "default.postgres15"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name      = aws_db_subnet_group.rds_subnet_group.name
}

output "rds_connection_string" {
  sensitive = true
  value = "postgres://${aws_db_instance.default.username}:${aws_db_instance.default.password}@${aws_db_instance.default.endpoint}/${aws_db_instance.default.identifier}"
}
