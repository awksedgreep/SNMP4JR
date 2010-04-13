#!/usr/bin/env jruby

require 'rubygems'
require 'SNMP4JR'

target = SNMPTarget.new(:host => '127.0.0.1', :community => 'private')

# Set your sysLocation
location = SNMP4JR::SMI::OctetString.new('30k Leagues Under the Sea')
target.set('1.3.6.1.2.1.1.6.0', location)

# Set your sysContact
email = SNMP4JR::SMI::OctetString.new('boogie@basketball.com')
target.set('1.3.6.1.2.1.1.4.0', email)

