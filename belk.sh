#!/bin/bash
#install basic elastic 

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
sudo apt-get install apt-transport-https   
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

sudo apt-get update && sudo apt-get install elasticsearch
#for master node install kibana
#sudo apt install kibana
#edit config for splash page
#/etc/kibana/kibana.yml
   #server.host: "0.0.0.0"
   
   #create token
   #/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana
   #got to server address ip:5601 and paste in token   
   
   #get OTP
   #/usr/share/kibana/bin/kibana-verification-code - put in code

   #reset elastic password
   #/usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic -i

#notes ADD NODES 
#edit "/etc/elasticsearch/elasticsearch.yml" first before starting service

  #cluster.name: my-application
  #node.name: node-1 (change for each node ex node-2, node-3...etc)
  #network.host: 10.3.10.155 ( ip addr of node)
  #http.port: 9200

#once edited get token from master 
  #/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node
  #***generate new token for each node****

#copy and paste into joining node
  #/usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token <enrollment-token>
#***generate new token for each node****

  #start elastic
  #systemctl daemon-reload
  #systemctl enable elasticsearch.service
  #systemctl start elastic

#profit








