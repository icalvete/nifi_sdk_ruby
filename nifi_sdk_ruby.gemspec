# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nifi_sdk_ruby/version'

Gem::Specification.new do |gem|
  gem.name          = "nifi_sdk_ruby"
  gem.version       = NifiSdkRuby::VERSION
  gem.authors       = ["Israel Calvete"]
  gem.email         = ["icalvete@gmail.com"]

  gem.summary       = %q{A RUBY SDK to use APACHE NIFI API}
  gem.description   = %q{See more at https://nifi.apache.org/ }
  gem.homepage      = "http://rubygems.org/gems/nifi-sdk-ruby"
  gem.license       = "GNU"
  gem.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|gem|features)/})
  end
  gem.bindir        = "exe"
  gem.executables   = gem.files.grep(%r{^exe/}) { |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_dependency 'httparty', '>= 0.14.0'
  gem.add_dependency 'curb', '>= 0.9.3'
  gem.add_dependency 'json', '>= 1.8.3'
  gem.add_dependency 'activesupport', '>= 5.0.2'
  gem.add_dependency 'nokogiri', '>= 1.6.7.2'

  gem.add_development_dependency "bundler", "~> 1.14"
  gem.add_development_dependency "rake", "~> 10.0"
  gem.add_development_dependency "rspec", "~> 3.0"
end
