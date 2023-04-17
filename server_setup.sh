#!/bin/bash
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