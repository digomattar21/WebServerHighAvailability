resource "aws_launch_template" "example" {
  name_prefix            = "rodry-lt-tf"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = aws_key_pair.example.key_name

  # user_data = base64encode(file("server_setup.sh"))
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

   iam_instance_profile {
    name = aws_iam_instance_profile.ec2_secrets_manager_profile.name
  }
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
