require_relative 'lib/inline_transforms/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 3.4'

  spec.name          = 'inline_transforms'
  spec.version       = InlineTransforms::VERSION
  spec.authors       = ['Nestor Custodio']
  spec.email         = ['nestor@custodio.org']

  spec.summary       = 'Facilitates inline value logic.'
  spec.homepage      = 'https://github.com/nestor-custodio/inline_transforms'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0") & Dir['*', 'lib/**/*']
  spec.executables   = []
  spec.require_paths = ['lib']

  # ---

  spec.metadata = {
    # See: https://guides.rubygems.org/specification-reference/#metadata

    # RubyGems.org Security
    #
    'allowed_push_host'     => 'https://rubygems.org',
    'rubygems_mfa_required' => 'true',

    # Metadata-Provided URIs
    #
    'homepage_uri'          => spec.homepage,
    'changelog_uri'         => "#{spec.homepage}/blob/main/CHANGELOG.md"
  }
end
