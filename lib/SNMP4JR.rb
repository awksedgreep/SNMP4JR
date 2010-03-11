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

class SNMPTarget
   attr_accessor :host, :community, :timeout, :version, :max_repetitions, :non_repeaters, :port
   attr_reader :request_type, :snmp, :result, :pdus_sent
   
   def initialize(ivar = {:host => '127.0.0.1', :community => 'public', :timeout => 2000, 
                     :version => SNMP4JR::MP::Version2c, :transport => 'udp',
                     :oids => ['1.3.6.1.2.1.1.1', '1.3.6.1.2.1.1.5'], :pdu => nil,
                     :max_repetitions => 1, :non_repeaters => 2})
      @host = ivar[:host]
      @community = ivar[:community]
      @timeout = ivar[:timeout]
      @version = SNMP4JR::MP::Version2c if ivar[:version].nil?
      @version = ivar[:version] unless ivar[:version].nil?
      @transport = ivar[:transport]
      @transport = 'udp' if @transport.nil?
      @pdu = ivar[:pdu]
      @oids = ivar[:oids]
      @max_repetitions = ivar[:max_repetitions]
      @non_repeaters = ivar[:non_repeaters]
      @port = 161 if ivar[:port].nil?
      @port = ivar[:port] unless ivar[:port].nil?
      @result = []
      @pdus_sent = 0
      @request_type = SNMP4JR::Constants::GETBULK
   end
   
   def pdu
      return @pdu unless @pdu.nil?
      @pdu = SNMP4JR::PDU.new
      @oids.each do |oid|
         @pdu.add(SNMP4JR::SMI::VariableBinding.new(SNMP4JR::SMI::OID.new(oid)))
      end
      @pdu.max_repetitions = @max_repetitions
      @pdu.non_repeaters = @non_repeaters
      @pdu.type = @request_type
      return @pdu
   end
   
   def pdu=(ivar)
      @pdu = ivar
      @oids = nil
   end
   
   def snmp_target
      @snmp_target unless @snmp_target.nil?
      @snmp_target = SNMP4JR::CommunityTarget.new
      @snmp_target.community = SNMP4JR::SMI::OctetString.new(@community)
      @snmp_target.address = SNMP4JR::SMI::GenericAddress.parse("#{@transport}:#{@host}/#{@port}")
      @snmp_target.version = @version
      @snmp_target.timeout = @timeout
      @snmp_target
   end
   
   def snmp_target=(target)
      @snmp_target = target
   end
   
   def oids
      if @oids.class == String
         @oids = [@oids]
      end
      return @oids
   end
   
   def oids=(oids)
      @oids = oids
      @pdu = nil
   end
   
   def transport
      if @transport.class == String
         case @transport
         when 'udp'
            return SNMP4JR::Transport::DefaultUdpTransportMapping.new
         when 'tcp'
            return SNMP4JR::Transport::DefaultTcpTransportMapping.new
         else
            return SNMP4JR::Transport::DefaultUdpTransportMapping.new
         end
      else
         return @transport
      end
   end
   
   def transport=(ivar)
      @transport = ivar
   end
   
   def get(oid_list = nil)
      self.oids = oid_list unless oid_list.nil?
      @request_type = SNMP4JR::Constants::GET
      reset_session
      @snmp = SNMP4JR::Snmp.new(transport)
      @snmp.listen
      @response = @snmp.send(pdu, snmp_target)
      @snmp.close
      @response.response.variable_bindings.first.variable unless @response.nil?
   end
   
   def get_bulk(oid_list = nil)
      self.oids = oid_list unless oid_list.nil?
      @request_type = SNMP4JR::Constants::GETBULK
      reset_session
      @snmp = SNMP4JR::Snmp.new(transport)
      @snmp.listen
      @response = @snmp.send(pdu, snmp_target)
      @snmp.close
      @response.response.variable_bindings unless @response.nil?
   end
   
   def walk(oid = nil)
      self.oids = [oid] unless oid.nil?
      snmp_oid = SNMP4JR::SMI::OID.new(oid)
      case version
      when SNMP4JR::MP::Version1
         @request_type = SNMP4JR::Constants::GETNEXT
      when (SNMP4JR::MP::Version2c or SNMP4JR::MP::Version3)
         @request_type = SNMP4JR::Constants::GETBULK
         @max_repetitions = 40
         @non_repeaters = 0
      end
      # tick a pdu for async to return when complete
      @pdus_sent += 1
      # track when I'm finished polling
      finished = false
      @result = []
      @snmp = SNMP4JR::Snmp.new(transport)
      @snmp.listen
      until finished
         response_event = @snmp.send(pdu, snmp_target)
         pp response_event.response
         response_pdu = response_event.response
         response_array = []
         response_array = pdu_to_ruby_array(response_pdu) unless response_pdu.nil?
         # timeout
         if response_pdu.nil?
            finished = true
         # nontimeout error
         elsif response_pdu.error_status != 0
            finished = true
         # returned no oids but was not an error (end of tree?)
         elsif response_array.length == 0
            finished = true
         # lexical compare, are we done with the tree?
         elsif !response_array.last.oid.starts_with(snmp_oid)
            finished = true
         end
         if (response_array.length > 0)
            # only add results that match filter
            @result += response_array.select { |vb| vb.oid.starts_with(snmp_oid) }
            # start next poll with last oid from
            self.oids = [response_array.last.oid.to_s]
         end
      end
      @pdus_sent -= 1
      @snmp.close
      @result
   end
   
   def walk_interfaces
      walk('1.3.6.1.2.1.2')
   end
   
   def walk_ifX
      walk('1.3.6.1.2.1.31')
   end
   
   def walk_full_interfaces
      output = walk_interfaces
      output += walk_ifX
      @result = output
   end
   
   def walk_system
      walk('1.3.6.1.2.1.1')
   end
   
   def walk_volumes
      walk('1.3.6.1.2.1.25.3.8')
   end
   
   def walk_resources
      walk('1.3.6.1.2.1.25.2.3.1')
   end
   
   def walk_software
      walk('1.3.6.1.2.1.25.6.3.1')
   end
   
   def walk_processes
      walk('1.3.6.1.2.1.25.4.2.1')
   end
   
   def nonblocking_walk(oid = nil)
   end
   
   def send(callback = nil)
      callback = self if callback.nil?
      @result = []
      @snmp = SNMP4JR::Snmp.new(transport)
      @snmp.listen
      @snmp.send(pdu, snmp_target, self, callback)
      @snmp.close
      @pdus_sent += 1
   end
   
   def onResponse(event)
      event.source.cancel(event.request, self)
      @result << {:target => event.user_object, :request => event.request, :response => event.response, :event => event}
      @pdus_sent -= 1
   end
   
   def poll_complete?(blocking = true)
      if blocking
         loop do
            return true if @pdus_sent == 0
            sleep 0.1
         end
      else
         if @pdus_sent == 0
            true
         else
            false
         end
      end
   end
   
   def result_to_s
      output = ''
      @result.each do |res|
         output += (res.to_s + "\n") if res.class == Java::OrgSnmp4jSmi::VariableBinding
         if res.class == Array
            res.each do |hash_event|
               hash_event.response.variable_bindings.each do |vb|
                  output += (vb.to_s + "\n")
               end
            end
         end
      end
      output
   end
   
   private
   def reset_session
      @pdu = nil unless @oids.nil?
      @snmp_target = nil
      @result = []
      @pdus_sent = 0
   end
   
   def pdu_to_ruby_array(ipdu)
      iresult = []
      ipdu.variable_bindings.each do |vb|
         iresult << vb
      end
      iresult
   end
end


class SNMPMulti
   attr_accessor :targets
   attr_reader :result
   
   # Takes a list of targets and polls each
   def initialize(targets = [SNMPTarget.new(:host => '127.0.0.1', :community => 'public', :oids => ['1.3.6.1.2.1.1.1', '1.3.6.1.2.1.1.3']), 
                              SNMPTarget.new(:host => 'rubydb.ove.local', :community => 'public', :oids => ['1.3.6.1.2.1.1.5'])],
                               transport = 'udp')
      @targets = targets
      @result = []
      @transport = transport
   end
   
   # Handle PDU responses as they arrive, you don't need to call this
   def onResponse(event)
      event.source.cancel(event.request, self)
      @result << {:target => event.user_object, :request => event.request, :response => event.response, :event => event}
   end
   
   # Poll the device
   def poll
      snmp = SNMP4JR::Snmp.new(SNMP4JR::Transport::DefaultUdpTransportMapping.new) if @transport == 'udp'
      snmp = SNMP4JR::Snmp.new(SNMP4JR::Transport::DefaultTcpTransportMapping.new) if @transport == 'tcp'
      snmp.listen
      @targets.each do |target|
         snmp.send(target.pdu, target.snmp_target, target, self)
      end
   end
end