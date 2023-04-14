#!/bin/bash
yum update -y
yum install -y httpd
echo "Hello, World from John Galt!" > /var/www/html/index.html
systemctl enable httpd
systemctl start httpd