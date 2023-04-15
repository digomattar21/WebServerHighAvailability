#!/bin/bash
sudo apt-get update
sudo apt-get install -y curl
sudo curl -fsSL https://deb.nodesource.com/setup_14.x | sudo bash -
sudo apt-get install -y nodejs

sudo npm install -g create-react-app

create-react-app my-react-app

cd my-react-app

sudo npm install -g serve

npm run build

sudo serve -s build -l 80