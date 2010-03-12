#!/usr/bin/env jruby

require 'rubygems'
require 'SNMP4JR'

# This defaults to version 2c bulkwalk(most efficient method) unless you specify version1
target = SNMPTarget.new(:host => '127.0.0.1', :community => 'public', 
                        :version => SNMP4JR::MP::Version1)

target.walk('1.3.6.1.2.1.1') # system MIB
puts target.result_to_s