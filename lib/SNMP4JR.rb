#!/usr/bin/env jruby

if RUBY_PLATFORM =~ /java/
   require 'java'
   require 'log4j-1.2.9.jar'
   require 'SNMP4J.jar'
else
  warn "SNMP4JR is only for use with JRuby"
end

module SNMP4JR
  include_package 'org.snmp4j'
  
  module Constants
     GET = -96
     GETNEXT = -95
     GETBULK = -91
     INFORM = -90
     NOTIFICATION = -89
     REPORT = -88
     RESPONSE = -94
     SET = -93
     TRAP = -89
     V1TRAP = -92
  end
 
   module ASN1
     include_package 'org.snmp4j.asn1'
   end
 
   module Event
     include_package 'org.snmp4j.event'
   end
 
   module Log
     include_package 'org.snmp4j.log'
   end
 
   module MP
      Version1 = 0
      Version2c = 1
      Version3 = 3
      include_package 'org.snmp4j.mp'
   end
 
   module Security
     include_package 'org.snmp4j.security'
   end
 
   module SMI
     include_package 'org.snmp4j.smi'
   end
 
   module Test
     include_package 'org.snmp4j.test'
   end
 
   module Tools
     module Console
       include_package 'org.snmp4j.tools.console'
     end
   end
 
   module Transport
     include_package 'org.snmp4j.transport'
   end
 
   module Util
     include_package 'org.snmp4j.util'
   end
 
   module Version
     include_package 'org.snmp4j.version'
   end
end


class SNMPMulti
   attr_accessor :pdu, :oids, :targets
   attr_reader :response
   
   # Takes a list of targets and a pdu and polls each
   # Alternatively you can give it a list of oids and it will create a pdu for you
   # If you want more control(v3 USM targets, tcp instead of udp, etc) you can pass prebuilt snmp_target
   # inside your target hash like so target
   def initialize(targets = [{:name => 'My Laptop', :host => '127.0.0.1', :community => 'public'}],
                  oids = ['1.3.6.1.2.1.1.1', '1.3.6.1.2.1.1.3'], 
                  pdu = nil)
      @targets = targets
      @oids = oids
      @pdu = pdu
      @response = []
      @targets_built = false
   end
   
   # Handle PDU responses as they arrive, you don't need to call this
   def onResponse(event)
      event.source.cancel(event.request, self)
      @response << {:target => event.user_object, :request => event.request, :response => event.response}
   end
   
   # Poll the device
   def poll
      build_targets unless @targets_built
      build_pdu if @pdu.nil?
      snmp = SNMP4JR::Snmp.new(SNMP4JR::Transport::DefaultUdpTransportMapping.new)
      snmp.listen
      @targets.each do |target|
         snmp.send(@pdu, target[:snmp_target], target[:name], self)
      end
      #sleep 1 # alternatively this _could_ bet set to max timeout of targets
   end
   
   private
   # Build SNMP4J compliant targets from the array of hashes passed in
   def build_targets
      @targets.each do |target|
         if target[:snmp_target].nil?
            snmp_target = SNMP4JR::CommunityTarget.new
            snmp_target.community = SNMP4JR::SMI::OctetString.new(target[:community])
            snmp_target.address = SNMP4JR::SMI::GenericAddress.parse("udp:#{target[:host]}/161")
            snmp_target.version = SNMP4JR::MP::Version2c
            snmp_target.timeout = 5000
            target[:snmp_target] = snmp_target
         end
      end
      @targets_built = true
   end
   
   # Populate PDU from OIDs passed in
   def build_pdu
      @pdu = SNMP4JR::PDU.new
      @oids.each do |oid|
         @pdu.add(SNMP4JR::SMI::VariableBinding.new(SNMP4JR::SMI::OID.new(oid)))
      end
      @pdu.type = SNMP4JR::Constants::GETBULK
      @pdu.max_repetitions = 1
      @pdu.non_repeaters = @oids.length
   end
end