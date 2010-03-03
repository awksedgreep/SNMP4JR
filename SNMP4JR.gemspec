# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{SNMP4JR}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mark Cotner"]
  s.date = %q{2010-03-02}
  s.description = %q{High Performance SNMP Library for JRuby which wraps SNMP4J}
  s.email = %q{mark.cotner@gmail.com}
  s.extra_rdoc_files = ["CHANGELOG", "README.rdoc", "TODO.rdoc", "lib/SNMP4J.jar", "lib/SNMP4JR.rb", "lib/log4j-1.2.9.jar"]
  s.files = ["CHANGELOG", "README.rdoc", "Rakefile", "TODO.rdoc", "gem-public_cert.pem", "init.rb", "lib/SNMP4J.jar", "lib/SNMP4JR.rb", "lib/log4j-1.2.9.jar", "Manifest", "SNMP4JR.gemspec"]
  s.homepage = %q{http://github.com/awksedgreep/SNMP4JR}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "SNMP4JR", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{snmp4jr}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{High Performance SNMP Library for JRuby which wraps SNMP4J}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
