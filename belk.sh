#!/bin/bash

HOSTIP=$(hostname -I | awk '{print $1}')

# Install Basic Elastic 
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

sudo apt-get install apt-transport-https   
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

sudo apt-get update

configElasticsearch() {
  ## Modify "/etc/elasticsearch/elasticsearch.yml" first before starting service
  #nano /etc/elasticsearch/elasticsearch.yml

  ## User Prompt: Configure the cluster name in "/etc/elasticsearch/elasticsearch.yml"
  read -p "Enter the cluster name: " clusterName
  sed -i "s/#cluster.name: my-application/cluster.name: $clusterName/" /etc/elasticsearch/elasticsearch.yml
  echo
  ## User Prompt: Configure the node name in "/etc/elasticsearch/elasticsearch.yml"
  read -p "Enter the node name: " nodeName
  sed -i "s/#node.name: node-1/node.name: $nodeName/" /etc/elasticsearch/elasticsearch.yml
  echo

  ## User Prompt: Configure the network host in "/etc/elasticsearch/elasticsearch.yml"
  echo "network.host: $HOSTIP is set in /etc/elasticsearch/elasticsearch.yml"
  sed -i "s/#network.host: .*/network.host: $HOSTIP/" /etc/elasticsearch/elasticsearch.yml
  echo

  ## User Prompt: Uncomment http.port in "/etc/elasticsearch/elasticsearch.yml"
  echo "Uncommenting 'http.port: 9200' in /etc/elasticsearch/elasticsearch.yml"
  sed -i "s/#http.port: 9200/http.port: 9200/" /etc/elasticsearch/elasticsearch.yml
  echo

  ## Start Elasticsearch
  echo
  echo "Starting the ElasticSearch service..."
  systemctl daemon-reload
  systemctl enable elasticsearch.service
  systemctl start elasticsearch
  echo "ElasticSearch service has been started."
  echo
}

configKibana() {
  # Edit config for Splash Page for /etc/kibana/kibana.yml
  echo "Configuring Kibana..."
  echo "Creating Kibana Token..."
  
  echo "network.host: 0.0.0.0 is set in /etc/kibana/kibana.yml"

  sed -i 's/#server.host: "localhost"/server.host: "0.0.0.0"/g' /etc/kibana/kibana.yml | tr -d '\r'
  echo "Starting Kibana..."
  systemctl enable kibana
  systemctl start kibana

  echo "Waiting 30 seconds for Kibana to start..."
  sleep 30

  echo "Resetting password for the built-in superuser 'elastic'..."
  /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic

  echo "Creating backup user 'admin' with password 'Cyber!23'..."
  /usr/share/elasticsearch/bin/elasticsearch-users useradd admin -p Cyber\!23 -r superuser

  #Create Kibana Token
  kibanatoken=$(/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana)
  echo "Kibana token created"
  echo "~~~~~~~~~~~~~~~"
  echo " The enrollment token for the joining node is: "
  echo " $kibanatoken "
  echo "~~~~~~~~~~~~~~~"
  echo "Navigate to http://$HOSTIP:5601 and paste in the token to login."

  echo && read -n 1 -s -r -p "Press any key to continue" && echo


  kibanaotp=$(/usr/share/kibana/bin/kibana-verification-code)
  echo "Kibana OTP created"
  echo "~~~~~~~~~~~~~~~"
  echo " The enrollment token for the joining node is: "
  echo " $kibanaotp "
  echo "~~~~~~~~~~~~~~~"

  echo && read -n 1 -s -r -p "Press any key to continue" && echo
}

# Elastic Token Join for Non-Master Nodes
elasticTokenJoin() {
  if [[ $is_master == "y" ]]; then
    echo
    echo "This is the master node. So you should be getting the Elastic Node Joining Token."
    elasticenroll=$(/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node)
    echo "Elastic token created"
    echo "~~~~~~~~~~~~~~~"
    echo " The enrollment token for the joining node is: "
    echo " /usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token $elasticenroll "
    echo "~~~~~~~~~~~~~~~"
  else
    echo
    echo "ReIterating this is not the master node. Take your master Joining token ennrollment and do this now."
    read -p "Enter the Elastic Node Joining Token Only: " elasticToken
    echo && echo "/usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token $elasticToken"
    /usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token $elasticToken

  fi
  echo && read -n 1 -s -r -p "Press any key to continue" && echo
}

# Master Node & Install Kibana
read -p "Is this the master node? (y/n): " is_master
if [[ $is_master == "y" ]]; then
  sudo apt install kibana
  sudo apt-get install elasticsearch
  configElasticsearch  
  configKibana
  elasticTokenJoin
else
  echo
  echo "This is not the master node. Skipping Kibana installation."
  sudo apt-get install elasticsearch
  configElasticsearch
  elasticTokenJoin
fi

echo && echo "profit"
