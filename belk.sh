#!/bin/bash


HOSTIP=$(hostname -I | awk '{print $1}')

## Prompt user to uninstall any existing ElasticSearch packages
uninstallElasticsearch() {
  # Stop Elasticsearch service
  read -p "Do you want to uninstall any existing ElasticSearch packages? (y/N): " uninstallChoice

  if [[ $uninstallChoice == "y" ]]; then
    # Stop Elasticsearch service
    sudo systemctl stop elasticsearch.service

    # Disable Elasticsearch service
    sudo systemctl disable elasticsearch.service

    # Uninstall Elasticsearch package
    sudo apt-get remove --purge elasticsearch

    # Remove Elasticsearch data and logs
    sudo rm -rf /var/lib/elasticsearch/
    sudo rm -rf /var/log/elasticsearch/

    # Remove Elasticsearch configuration files
    sudo rm -rf /etc/elasticsearch/

    # Update the package list
    sudo apt-get update

    # Reinstall Elasticsearch
    # First, add the GPG key for the official Elasticsearch repository
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

    # Add the Elasticsearch repository
    echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

    # Update the package list again
    sudo apt-get update
  fi
}
uninstallElasticsearch


#### install basic elastic 
installElasicsearch() {
  # Install the apt-transport-https package
  sudo apt-get install -y apt-transport-https

  # Update the package list and install Elasticsearch
  sudo apt-get update && sudo apt-get install elasticsearch -y

## Download and import the GPG key for Elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

### Add the Elasticsearch repository to the sources list
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

### Update the package list and install Elasticsearch
sudo apt-get update && sudo apt-get install -y elasticsearch
}
installElasicsearch


modifyElasticsearchConfig() {
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
  sed -i "s/#network.host: 192.168.0.1/network.host: $(hostname -I | awk '{print $1}')/" /etc/elasticsearch/elasticsearch.yml
  echo

  ## User Prompt: Uncomment http.port in "/etc/elasticsearch/elasticsearch.yml"
  echo "Uncommenting 'http.port: 9200' in /etc/elasticsearch/elasticsearch.yml"
  sed -i "s/#http.port: 9200/http.port: 9200/" /etc/elasticsearch/elasticsearch.yml
  echo

  ## Start Elasticsearch
  echo "Starting the ElasticSearch service..."
  systemctl daemon-reload
  systemctl enable elasticsearch.service
  systemctl start elasticsearch
  echo "ElasticSearch service has been started."
}
modifyElasticsearchConfig

## Once edited, obtain the enrollment token from the master node
node1token=$(/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node)
# E.g.: eyJ2ZXIiOiI4LjE0LjAiLCJhZHIiOlsiMTAuMS4zLjE1MDo5MjAwIl0sImZnciI6IjMxODUwZDk3MzFlMTEyNzBiNTkwMjYyNDJmYTNjMWUyN2U0MWJlODMzNzYwYzg5NmNhNjhkODIyMmFiMDliNWQiLCJrZXkiOiJac1NnUHBBQjk1bWRscEVKSmFFXzo3cmp2QldBN1M1NlRwRHJackhHcmZBIn0=
echo "~~~~~~~~~~~~~~~"
echo " The enrollment token for the joining node is: "
echo " $node1token "
echo "~~~~~~~~~~~~~~~"
echo

## Paste the enrollment token into the joining node
echo "-----------------------------------------------------------------"
echo "Now take the following command and run it on the joining node after setting up the secondary nodes"
echo
echo "/usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token $node1token"
echo "-----------------------------------------------------------------"
### ~~~ ***Generate a new token for each node*** ~~~ ###
echo

## User Prompt: Check the status of the ElasticSearch service or do a Test Curl
while true; do
  read -p "Do you want to check the status of the ElasticSearch service? 
  [1] - Check the status of the ElasticSearch service
  [2] - Test Curl to http://$HOSTIP:9200
  Choice: " choice
  case $choice in
    1 )
      systemctl status elasticsearch
      ;;
    2 )
      curl http://$HOSTIP:9200
      ;;
    [Nn]* )
      break
      ;;
    [Qq]* )
      exit
      ;;
    * )
      echo "Please answer 1, 2, q."
      ;;
  esac
done

#profit
