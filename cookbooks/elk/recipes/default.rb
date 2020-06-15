#
# Cookbook:: elk
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.
package 'epel-release'

package 'java-1.8.0-openjdk'

package 'nginx'

# directory "#{node['nginx']['conf.d']}" do
directory node['nginx']['conf.d'] do
  mode '0755'
end

template "#{node['nginx']['conf.d']}kibana.conf" do
  source 'kibana.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template "#{node['nginx']['root']}nginx.conf" do
  source 'nginx.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

# if node['platform'] == 'centos'
if platform?('centos')
  yum_repository 'elasticsearch' do
    baseurl 'https://artifacts.elastic.co/packages/7.x/yum'
    description 'Elasticsearch repository for 7.x packages'
    enabled true
    gpgcheck true
    gpgkey 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'
    action :create
  end
end

yum_package 'elasticsearch' do
  flush_cache [ :before ]
end

template "#{node['elasticsearch']['root']}elasticsearch.yml" do
  source 'elasticsearch.yml.erb'
  owner 'root'
  group 'elasticsearch'
  mode '0750'
end

template "#{node['elasticsearch']['root']}jvm.options" do
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

template "#{node['kibana']['root']}kibana.yml" do
  source 'kibana.yml.erb'
  owner 'root'
  group 'kibana'
  mode '0750'
end

execute '5601_firewall' do
  command '/usr/bin/firewall-cmd  --permanent --zone public --add-port=5601/tcp'
  ignore_failure true
end

execute 'reload_firewall' do
  command '/usr/bin/firewall-cmd --reload'
  ignore_failure true
end

node['packages']['start'].each do |package|
  service package do
    action [:enable, :start]
  end
end

hook = data_bag_item('hooks', 'requests')

http_request 'callback' do
  url hook['url']
end

yum_repository 'logstash' do
  baseurl 'https://artifacts.elastic.co/packages/7.x/yum'
  description 'Logstash repository for 7.x packages'
  enabled true
  gpgcheck true
  gpgkey 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'
  action :create
end

yum_package 'logstash' do
  flush_cache [ :before ]
end

template "#{node['logstash']['root']}logstash.yml" do
  source 'logstash.yml.erb'
  owner 'root'
  group 'logstash'
  mode '0750'
end

template "#{node['logstash']['root']}jvm.options" do
  source 'jvm.logstash.erb'
  owner 'root'
  group 'logstash'
  mode '0750'
end

execute 'generate logstash.service file for systemd' do
  command '/usr/share/logstash/bin/system-install /etc/logstash/startup.options systemd'
#  action :nothing
end

execute 'start logstash' do
  command 'systemctl start logstash.service'
#  action :nothing
end
