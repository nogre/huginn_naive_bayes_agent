# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'huginn_naive_bayes_agent/version'

Gem::Specification.new do |spec|
  spec.name          = "huginn_naive_bayes_agent"
  spec.version       = HuginnNaiveBayesAgent::VERSION
  spec.authors       = ["Noah Greenstein"]
  spec.email         = ["ng03@noahgreenstein.com"]

  spec.summary       = %q{Naive Bayes Agent for Huginn.}
  spec.description   = %q{The Huginn Naive Bayes agent uses some incoming Events as a training set for Naive Bayes Machine Learning. Then it classifies Events from other sources accordingly using tags. Acts as a Huginn Agent front end to the NBayes gem (https://github.com/oasic/nbayes).}
  spec.homepage      = "https://github.com/nogre/huginn_naive_bayes_agent"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  #if spec.respond_to?(:metadata)
  #  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  #else
  #  raise "RubyGems 2.0 or newer is required to protect against " \
  #    "public gem pushes."
  #end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency "yaml"
  spec.add_runtime_dependency "nbayes"
  spec.add_runtime_dependency "huginn_agent"
end
