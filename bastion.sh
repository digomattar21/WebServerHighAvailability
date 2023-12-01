#!/bin/bash
sudo apt-get update -y
wget https://git.io/fxZq5 -O guac-install.sh
chmod +x guac-install.sh
sudo ./guac-install.sh --mysqlpwd password --guacpwd password
