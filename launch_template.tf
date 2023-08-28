resource "aws_launch_template" "example" {
  name_prefix            = "rodry-lt-tf"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = aws_key_pair.example.key_name

  # user_data = base64encode(file("server_setup.sh"))
  user_data = base64encode(<<-EOT
                            #!/bin/bash

                            # Update and Install AWS CLI
                            sudo apt-get update
                            sudo apt-get install -y awscli curl

                            # Fetch SSH Key for Git
                            mkdir -p ~/.ssh
                            sudo snap install jq
                            aws secretsmanager get-secret-value --region us-east-2 --secret-id git_key --query SecretString --output text | jq -r .git_key | sed 's/\\n/\n/g' | sudo tee ~/.ssh/id_rsa > /dev/null
            
                            sudo chmod 600 ~/.ssh/id_rsa

                            # Set Environment Variables
                            echo "export PORT=8080" | sudo tee -a /etc/environment > /dev/null
                            echo "export CELCOIN_BASE_URL=sandbox.openfinance.celcoin.dev" | sudo tee -a /etc/environment > /dev/null
                            echo "export CELCOIN_BOLETO_CLIENT_ID=41b44ab9a56440.teste.celcoinapi.v5" | sudo tee -a /etc/environment > /dev/null
                            echo "export CELCOIN_BOLETO_CLIENT_SECRET=e9d15cde33024c1494de7480e69b7a18c09d7cd25a8446839b3be82a56a044a3" | sudo tee -a /etc/environment > /dev/null
                            echo "export CELCOIN_BOLETO_GRANT_TYPE=client_credentials" | sudo tee -a /etc/environment > /dev/null
                            echo "export OCR_BASE_URL=pago-ocr.herokuapp.com" | sudo tee -a /etc/environment > /dev/null
                            echo "export CELCOIN_BAAS_CLIENT_ID=18895cab60.pago.celcoinapi.v5" | sudo tee -a /etc/environment > /dev/null
                            echo "export CELCOIN_BAAS_CLIENT_SECRET=3c86d09fed594577acca742bf2c0e8742bd0ea78af7f4b4d8d0eb92ee12c3df1" | sudo tee -a /etc/environment > /dev/null
                            echo "export CELCOIN_BAAS_GRANT_TYPE=client_credentials" | sudo tee -a /etc/environment > /dev/null
                            echo "export ACCESS_TOKEN_EXPIRES_IN=100m" | sudo tee -a /etc/environment > /dev/null
                            echo "export REFRESH_TOKEN_EXPIRES_IN=21d" | sudo tee -a /etc/environment > /dev/null
                            echo "export ACCESS_TOKEN_SECRET_KEY=6c2c6123fa95463eae0a57f316e8c2489caf58f6" | sudo tee -a /etc/environment > /dev/null
                            echo "export REFRESH_TOKEN_SECRET_KEY=67553f599f8162b23cabbcf24337e09466c67526" | sudo tee -a /etc/environment > /dev/null
                            echo "export REGCHEQ_BASE_URL=external-api.regcheq.com" | sudo tee -a /etc/environment > /dev/null
                            echo "export REGCHEQ_API_KEY=057479CA0B75345552914D36" | sudo tee -a /etc/environment > /dev/null
                            echo "export BIGDATA_TOKEN_BASE_URL=accesstoken.bigdatacorp.com.br" | sudo tee -a /etc/environment > /dev/null
                            echo "export BIGDATA_BASE_URL=app.bigdatacorp.com.br" | sudo tee -a /etc/environment > /dev/null
                            echo "export POSTGRES_HOST=localhost" | sudo tee -a /etc/environment > /dev/null
                            echo "export POSTGRES_PORT=5432" | sudo tee -a /etc/environment > /dev/null
                            echo "export POSTGRES_USER=postgres" | sudo tee -a /etc/environment > /dev/null
                            echo "export POSTGRES_DB=pago" | sudo tee -a /etc/environment > /dev/null
                            echo "export EMAIL_SHOOTER_API_KEY=2P8hVsdXkZ8H7ITNqjs7r19NNjyQFBSQ6lO1n8wE" | sudo tee -a /etc/environment > /dev/null
                            echo "export PAGO_PIX_KEY=4b6fc173-56a2-46ec-8f96-c97452e7b732" | sudo tee -a /etc/environment > /dev/null
                            echo "export PAGO_RECEIVER_NAME=Pagô" | sudo tee -a /etc/environment > /dev/null
                            echo "export PAGO_RECEIVER_POSTAL_CODE=04513030" | sudo tee -a /etc/environment > /dev/null
                            echo "export PAGO_RECEIVER_CITY=São Paulo" | sudo tee -a /etc/environment > /dev/null
                            echo "export PAGO_RECEIVER_PUBLIC_AREA=04513030" | sudo tee -a /etc/environment > /dev/null
                            echo "export PAGO_RECEIVER_POSTAL_CODE=Monte aprazível" | sudo tee -a /etc/environment > /dev/null
                            echo "export PAGO_RECEIVER_STATE=SP" | sudo tee -a /etc/environment > /dev/null
                            echo "export PAGO_RECEIVER_CNPJ=47897808000187" | sudo tee -a /etc/environment > /dev/null
                            echo "export S3_AUTOMATOR_BUCKET=eaipago-automator" | sudo tee -a /etc/environment > /dev/null
                            echo "export AWS_ACCESS_KEY_ID=AKIAZEIPHH3Z7PG4GYXK" | sudo tee -a /etc/environment > /dev/null
                            echo "export AWS_SECRET_ACCESS_KEY=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" | sudo tee -a /etc/environment > /dev/null
                            echo "export REDIS_PASSWORD=pagoRedis" | sudo tee -a /etc/environment > /dev/null
                            echo "export REDIS_PORT=37" | sudo tee -a /etc/environment > /dev/null
                            echo "export DATABASE_URL=postgresql://postgres:postgres@${aws_db_instance.default.endpoint}/postgres?schema=public" | sudo tee -a /etc/environment > /dev/null
                            echo "export REDIS_HOST=${aws_elasticache_cluster.redis_cluster.cache_nodes[0].address}" | sudo tee -a /etc/environment > /dev/null
                            source /etc/environment

                            # Install Node.js and Yarn
                            sudo curl -fsSL https://deb.nodesource.com/setup_18.x | sudo bash -
                            sudo apt-get install -y nodejs
                            sudo npm install -g yarn

                            # Clone the Repository and Install Dependencies
                            # GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" sudo git clone git@github.com:Eai-Pago/the-api.git
                            # cd the-api
                            # yarn
                            git clone https://github.com/coderonfleek/simple-node-api.git
                            cd simple-node-api
                            npm install
                            node server

                            # Run db commands
                            # npx prisma generate
                            # npx prisma db push
                            # npx prisma db seed

                            # Start the Node.js App
                            # If you still want to run it on port 80 directly:
                            # sudo setcap 'cap_net_bind_service=+ep' $(which node)
                            # sudo yarn start 

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
