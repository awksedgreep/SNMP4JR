#!/usr/bin/env jruby

require 'rubygems'
#require 'SNMP4JR'
require '../lib/SNMP4JR'
require 'pp'

m = SNMPMulti.new([{:name => 'macbookpro', :host => '127.0.0.1', :community => 'public'},
                   {:name => 'macpro', :host => '192.168.0.254', :community => 'public'}])

# Please note that by default the PDU that is build by SNMPMulti will be a GETBULK request
# Per SNMP2c specification this means each oid should be expected to be a GETNEXT request
# therefore you will need to specify either the root of a tree(1.3.6.1.2.1.1.1 vs 1.3.6.1.2.1.1.1.0)
# or specify the oid just before the request you would like to make
# If you would like to change this behavior you need to build your own PDU and pass it in(see example snmpmulti_async_w_pdu.rb)
m.oids = ['1.3.6.1.2.1.1.1', '1.3.6.1.2.1.1.3']
m.poll
sleep 5 # wait for all pdus to return and get processed
m.response.each do |result|
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
