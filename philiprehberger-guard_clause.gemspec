# frozen_string_literal: true

require_relative 'lib/philiprehberger/guard_clause/version'

Gem::Specification.new do |spec|
  spec.name = 'philiprehberger-guard_clause'
  spec.version = Philiprehberger::GuardClause::VERSION
  spec.authors = ['Philip Rehberger']
  spec.email = ['me@philiprehberger.com']

  spec.summary = 'Expressive guard clause DSL for method precondition validation'
  spec.description = 'A chainable guard clause DSL for validating method preconditions with built-in checks ' \
                       'for nil, empty, numeric bounds, regex matching, inclusion, and soft mode error collection.'
  spec.homepage = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-guard_clause'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/philiprehberger/rb-guard-clause'
  spec.metadata['changelog_uri'] = 'https://github.com/philiprehberger/rb-guard-clause/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/philiprehberger/rb-guard-clause/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
