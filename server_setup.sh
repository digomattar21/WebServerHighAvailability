#!/bin/bash
apt-get update
apt-get install -y apache2
systemctl enable apache2
systemctl start apache2

# Create the custom HTML file
cat > /var/www/html/index.html <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Custom Web Server</title>
</head>
<body>
  <h1>Welcome to my custom web server!</h1>
  <p>This is a simple web page served by the Apache web server on an Ubuntu instance.</p>
</body>
</html>
EOL