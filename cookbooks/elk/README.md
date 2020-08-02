# Setting Up ELK Stack (Elasticsearch - Logstash - Kibana)

This cookbook is able to install elasticsearch and kibana through reverse proxy based on NGINX, also install and configure logstash with a pipeline that retrieve data from wheather API and  these store on elasticsearch node, these data will show through of kibana dashboard that is setting up through of the cookbook as well. Is important that the server where will be deployed this cookbook has at least 3 GB RAM and 2 CPU´s.

# Pre-requirements

This cookbook runs on the follow versions of Chef (SCM tool):
* ChefDK version: 4.7.73
* Chef Infra Client version: 15.7.32
* Chef InSpec version: 4.18.51
* Test Kitchen version: 2.3.4
* Foodcritic version: 16.2.0
* Cookstyle version: 5.20.0

# Installation

After You have download the project within cookbooks directory on your chef-repo (default workdirectory for Chef Workstation), You need upload the cookbook on Chef Server and You could bootstrap a Chef Node with this cookbook.

# Author
Carlos Hernández
