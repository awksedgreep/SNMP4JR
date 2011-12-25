#!/usr/bin/env jruby

require 'rubygems'
require 'SNMP4JR'
#require '../lib/SNMP4JR'

# Specify your targets
target1 = SNMPTarget.new({:name => 'macbookpro', :host => '127.0.0.1', :community => 'public'})
target2 = SNMPTarget.new({:name => 'macpro', :host => '192.168.0.254', :community => 'public'})

# tell each target what to poll
# Please note that by default the PDU that is build by SNMPMulti will be a GETBULK request
# Per SNMP2c specification this means each oid should be expected to be a GETNEXT request
# therefore you will need to specify either the root of a tree(1.3.6.1.2.1.1.1 vs 1.3.6.1.2.1.1.1.0)
# or specify the oid just before the request you would like to make
oids = ['1.3.6.1.2.1.1.1', '1.3.6.1.2.1.1.5']
target1.oids = oids
target2.oids = oids

# Now use Multi to poll alll devices at the same time.  It handles the necessary callbacks
# and PDU alignment for you
multi = SNMPMulti.new(target1, target2)

# Begin the poll
multi.poll
sleep 3 # wait for all pdus to return and get processed
multi.result.each do |result|
   pp result
   if result[:response].nil?
      puts "Request to host timed out"
   else
      puts result[:event].peer_address.to_s
      result[:response].variable_bindings.each do |vb|
         puts vb.oid.to_s + " => " + vb.variable.to_s
      end 
   end
end
