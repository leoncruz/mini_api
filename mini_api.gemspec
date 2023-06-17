# frozen_string_literal: true

require_relative 'lib/mini_api/version'

Gem::Specification.new do |spec|
  spec.name        = 'mini_api'
  spec.version     = MiniApi::VERSION
  spec.authors     = ['Leon Cruz']
  spec.email       = ['leon.cruz.teixeira@gmail.com']
  spec.summary     = 'A collection of resources to create restful apis'
  spec.description = 'A collection of resources to create restful apis'
  spec.license     = 'MIT'

  spec.required_ruby_version = '~> 3.0'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'rails', '>= 7.0.5'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
