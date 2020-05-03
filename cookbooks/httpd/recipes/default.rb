#
# Cookbook:: httpd
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.
package 'httpd'

service 'httpd' do
  action [:enable,:start]
end

package 'firewalld'

service 'firewalld' do
  action [:enable, :start]
end

template '/var/www/html/index.html' do
  source 'index.html.erb'
end

execute 'httpd_firewall' do
  command '/usr/bin/firewall-cmd  --permanent --zone public --add-service http'
  ignore_failure true
end

execute 'reload_firewall' do
  command '/usr/bin/firewall-cmd --reload'
  ignore_failure true
end

