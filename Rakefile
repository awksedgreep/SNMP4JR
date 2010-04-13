require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('SNMP4JR', '0.0.17') do |p|
  p.description             = "High Performance SNMP Library for JRuby which wraps SNMP4J"
  p.url                     = "http://github.com/awksedgreep/SNMP4JR"
  p.author                  = "Mark Cotner"
  p.email                   = "mark.cotner@gmail.com"
  p.ignore_pattern          = ["tmp/*", "script/*"]
  p.development_dependencies= []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
