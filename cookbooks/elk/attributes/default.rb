default['nginx']['conf.d'] = '/etc/nginx/conf.d/'
default['nginx']['root'] = '/etc/nginx/'
default['elasticsearch']['root'] = '/etc/elasticsearch/'
default['kibana']['root'] = '/etc/kibana/'
default['logstash']['root'] = '/etc/logstash/'
# default['packages']['start'] = ['kibana', 'nginx']
default['packages']['start'] = %w(kibana nginx)
