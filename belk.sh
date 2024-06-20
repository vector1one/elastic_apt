#!/bin/bash
#install basic elastic 

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
sudo apt-get install apt-transport-https   

echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
echo "action.auto_create_index: .monitoring*,.watches,.triggered_watches,.watcher-history*,.ml*" >> /etc/elasticsearch/elasticsearch.yml


sudo apt-get update && sudo apt-get install elasticsearch

sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service



#cluster
#/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node
#/usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token <enrollment-token>
