# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  subnet_ids = [aws_subnet.private[1].id]

  description = "Redis subnet group"
}

# Redis ElastiCache Cluster
resource "aws_elasticache_cluster" "redis_cluster" {
  cluster_id           = "redis-cluster"
  engine               = "redis"
  node_type            = "cache.t2.micro"  # Cheapest instance type for Redis
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.redis_param_group.name
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids   = [aws_security_group.redis.id]
}

resource "aws_elasticache_parameter_group" "redis_param_group" {
  name        = "custom-redis7"
  family      = "redis7"
  description = "Custom parameter group for redis7"
}