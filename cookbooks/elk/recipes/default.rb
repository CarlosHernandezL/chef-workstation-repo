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
end

execute 'start_logstash' do
  command 'systemctl start logstash.service'
end

chef_gem 'chef-vault' do
  compile_time true if respond_to?(:compile_time)
end

require 'chef-vault'

item = ChefVault::Item.load('api_weather', 'appid')

execute 'create keystore on logstash' do
  command "echo 'y' | /usr/share/logstash/bin/logstash-keystore --path.settings /etc/logstash create -x"
end

execute 'add key to logstash' do
  command "echo #{item['key']} | /usr/share/logstash/bin/logstash-keystore --path.settings /etc/logstash add API_KEY -x"
end

template "#{node['logstash']['root']}conf.d/weather.conf" do
  source 'weather.conf.erb'
  owner 'root'
  group 'logstash'
  mode '0750'
end

template '/tmp/dashboard.json' do
  source 'dashboard.json.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

http_request 'posting_dashboard_to_kibana' do
  action :post
  url 'http://localhost:5601/api/kibana/dashboards/import'
  message lazy { IO.read('/tmp/dashboard.json') }
  headers ({ 'kbn-xsrf' => 'reporting', 'Content-Type' => 'application/json' })
end
