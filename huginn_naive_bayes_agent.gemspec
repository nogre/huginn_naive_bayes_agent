# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "huginn_naive_bayes_agent"
  spec.version       = '0.1.3'
  spec.authors       = ["Noah Greenstein"]
  spec.email         = ["nogre1@noahgreenstein.com"]

  spec.summary       = %q{Naive Bayes Agent for Huginn.}
  spec.description   = %q{The Huginn Naive Bayes agent uses some incoming Events as a training set for Naive Bayes Machine Learning. Then it classifies Events from other sources accordingly using tags. Acts as a Huginn Agent front end to the NBayes gem (https://github.com/oasic/nbayes).}

  spec.homepage      = "https://github.com/nogre/huginn_naive_bayes_agent"

  spec.license       = "MIT"


  spec.files         = Dir['LICENSE.txt', 'lib/**/*']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = Dir['spec/**/*.rb'].reject { |f| f[%r{^spec/huginn}] }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "huginn_agent"
  spec.add_runtime_dependency "nbayes"
end
