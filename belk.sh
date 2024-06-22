#!/bin/bash
#### install basic elastic 

## Download and import the GPG key for Elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

### Install the apt-transport-https package
sudo apt-get install apt-transport-https   

### Add the Elasticsearch repository to the sources list
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

### Update the package list and install Elasticsearch
sudo apt-get update && sudo apt-get install elasticsearch

#@#  ~~~notes ~~~
#edit "/etc/elasticsearch/elasticsearch.yml" first before starting service

## Configure Elasticsearch settings in "/etc/elasticsearch/elasticsearch.yml"
## Uncomment and modify the following lines:
#   cluster.name: my-application
#   node.name: node-1
#   network.host: 10.3.10.155 (ip addr of node)
#   http.port: 9200

## Once edited, obtain the enrollment token from the master node
# /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node

## Paste the enrollment token into the joining node
# /usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token <enrollment-token>
### ~~~ ***Generate a new token for each node*** ~~~ ###

## Start Elasticsearch
# systemctl daemon-reload
# systemctl enable elasticsearch.service
# systemctl start elastic

#profit
