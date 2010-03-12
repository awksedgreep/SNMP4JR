#!/usr/bin/env jruby

require 'rubygems'
require 'SNMP4JR'

# This example uses the SNMP4J libraries directly from Ruby.  This is advanced use of the library.
# The wrappers are much simpler.  Check out the SNMPTarget and SNMPMulti classes for a much easier
# example.

# Open a new session
snmp = SNMP4JR::Snmp.new(SNMP4JR::Transport::DefaultUdpTransportMapping.new)
snmp.listen

# Set up your target, including timeout and version
target = SNMP4JR::CommunityTarget.new
target.community = SNMP4JR::SMI::OctetString.new('public') # community string to use
target.address = SNMP4JR::SMI::GenericAddress.parse("udp:127.0.0.1/161") # poll localhost, change this to suit
target.version = SNMP4JR::MP::Version2c # Set SNMP verion 2c
target.timeout = 5000 # 5 seconds

# Build your request PDU including type and oids to be polled
pdu = SNMP4JR::PDU.new
pdu.add(SNMP4JR::SMI::VariableBinding.new(SNMP4JR::SMI::OID.new('1.3.6.1.2.1.1.1')))
pdu.add(SNMP4JR::SMI::VariableBinding.new(SNMP4JR::SMI::OID.new('1.3.6.1.2.1.1.3')))
pdu.type = SNMP4JR::Constants::GETBULK
pdu.max_repetitions = 1
pdu.non_repeaters = 2

result = snmp.send(pdu, target)
puts result.peer_address.to_s + ': '
result.response.variable_bindings.each do |vb|
  puts vb.oid.to_s + " => " + vb.variable.to_s
end
