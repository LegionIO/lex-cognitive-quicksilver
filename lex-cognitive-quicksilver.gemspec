# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_quicksilver/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-quicksilver'
  spec.version       = Legion::Extensions::CognitiveQuicksilver::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Cognitive Quicksilver'
  spec.description   = 'Cognitive quicksilver fluidity for LegionIO agentic architecture'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-quicksilver'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-cognitive-quicksilver'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-cognitive-quicksilver'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-cognitive-quicksilver'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-cognitive-quicksilver/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }
  spec.require_paths = ['lib']
end
