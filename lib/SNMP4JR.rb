module SNMP4JR
  include_package 'org.snmp4j'

   module ASN1
     include_package 'org.snmp4j.asn1'
   end

   module Event
     include_package 'org.snmp4j.event'
   end

   module Log
     include_package 'org.snmp4j.log'
   end

   module Mp
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