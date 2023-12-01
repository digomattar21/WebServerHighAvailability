#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y postgresql postgresql-contrib
echo "listen_addresses='*'" | sudo tee -a /etc/postgresql/14/main/postgresql.conf
echo "host all all 0.0.0.0/0 md5" | sudo tee -a /etc/postgresql/14/main/pg_hba.conf
sudo systemctl restart postgresql
sudo apt-get install zabbix-agent -y
sudo systemctl start zabbix-agent
sudo systemctl enable zabbix-agent


sudo -u postgres psql <<EOF

-- Create a new database
CREATE DATABASE mydatabase;

-- Connect to the new database
\c mydatabase

-- Create a new table 'todos'
CREATE TABLE todos (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT
);

-- Insert sample data into 'todos'
INSERT INTO todos (name, description) VALUES ('Todo 1', 'Description for Todo 1');
INSERT INTO todos (name, description) VALUES ('Todo 2', 'Description for Todo 2');
INSERT INTO todos (name, description) VALUES ('Todo 3', 'Description for Todo 3');

EOF