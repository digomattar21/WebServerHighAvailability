resource "aws_instance" "web_server" {
  ami                    = "ami-0b61425d47a44fc5f"  
  instance_type          = "t2.micro"               
  key_name               = aws_key_pair.key.key_name  
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id              = aws_subnet.private[0].id

  user_data = base64encode(<<-EOT
                            #!/bin/bash

                            # Install Node.js and Yarn
                            sudo curl -fsSL https://deb.nodesource.com/setup_18.x | sudo bash -
                            sudo apt-get install -y nodejs
                            sudo npm install -g yarn

                           
                            git clone https://github.com/coderonfleek/simple-node-api.git
                            cd simple-node-api
                            npm install
                            export PORT=8080
                            node server

                            EOT 
   )

  tags = {
    Name = "WebServer"
  }
}

