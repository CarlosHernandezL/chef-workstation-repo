#
# Cookbook:: elk
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.
package 'epel-release'

package 'java-1.8.0-openjdk'

package 'nginx'

directory '/etc/nginx/conf.d/' do
  mode '0755'
end

template "/etc/nginx/conf.d/kibana.conf" do
  source 'kibana.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template "/etc/nginx/nginx.conf" do
  source 'nginx.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

yum_repository 'elasticsearch' do
  baseurl 'https://artifacts.elastic.co/packages/7.x/yum'
  description 'Elasticsearch repository for 7.x packages'
  enabled true
  gpgcheck true
  gpgkey 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'
  action :create
end

yum_package 'elasticsearch' do
  flush_cache [ :before ]
end

template "/etc/elasticsearch/elasticsearch.yml" do
  source 'elasticsearch.yml.erb'
  owner 'root'
  group 'elasticsearch'
  mode '0750'
end

template "/etc/elasticsearch/jvm.options" do
  source 'jvm.options.erb'
  owner 'root'
  group 'elasticsearch'
  mode '0750'
end

service 'elasticsearch' do
  action [:enable, :start]
end

package 'firewalld'

service 'firewalld' do
  action [:enable, :start]
end

execute 'httpd_firewall' do
  command '/usr/bin/firewall-cmd  --permanent --zone public --add-service http'
  ignore_failure true
end

execute '9200_firewall' do
  command '/usr/bin/firewall-cmd  --permanent --zone public --add-port=9200/tcp'
  ignore_failure true
end

execute 'reload_firewall' do
  command '/usr/bin/firewall-cmd --reload'
  ignore_failure true
end

yum_repository 'kibana' do
  baseurl 'https://artifacts.elastic.co/packages/7.x/yum'
  description 'Kibana repository for 7.x packages'
  enabled true
  gpgcheck true
  gpgkey 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'
  action :create
end

yum_package 'kibana' do
  flush_cache [ :before ]
end

template "/etc/kibana/kibana.yml" do
  source 'kibana.yml.erb'
  owner 'root'
  group 'kibana'
  mode '0750'
end

service 'kibana' do
  action [:enable, :start]
end

execute '5601_firewall' do
  command '/usr/bin/firewall-cmd  --permanent --zone public --add-port=5601/tcp'
  ignore_failure true
end

execute 'reload_firewall' do
  command '/usr/bin/firewall-cmd --reload'
  ignore_failure true
end

service 'nginx' do
  action [:enable, :start]
end
