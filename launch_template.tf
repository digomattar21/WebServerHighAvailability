resource "aws_launch_template" "example" {
  name_prefix            = "rodry-lt-tf"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = aws_key_pair.example.key_name

  # user_data = base64encode(file("server_setup.sh"))
   user_data = base64encode(<<-EOT
                            #!/bin/bash
                            echo "${local.env_file_content}" > /home/ubuntu/.env
                            chown ubuntu:ubuntu /home/ubuntu/.env
                            chmod 600 /home/ubuntu/.env
                            echo "export RDS_CONNECTION_STRING=${aws_db_instance.default.endpoint}" >> /etc/environment
                            echo "export REDIS_ENDPOINT=${aws_elasticache_cluster.redis_cluster.cache_nodes[0].address}" >> /etc/environment
                            source /etc/environment
                            sudo apt-get update
                            sudo apt-get install -y curl
                            sudo curl -fsSL https://deb.nodesource.com/setup_14.x | sudo bash -
                            sudo apt-get install -y nodejs
                            
                            sudo npm install -g yarn
                            
                            git clone https://github.com/digomattar21/portfolio.git
                            
                            cd portfolio
                            
                            yarn
                            
                            yarn build
                            
                            sudo yarn start --port 80
                            EOT 
   )
  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
    }
  }
}
