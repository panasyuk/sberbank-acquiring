lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sberbank/acquiring/version'

Gem::Specification.new do |spec|
  spec.name          = 'sberbank-acquiring'
  spec.version       = Sberbank::Acquiring::VERSION
  spec.authors       = ['Aleksandr Panasyuk']
  spec.email         = ['panasmeister@gmail.com']

  spec.summary       = 'GEM that makes integration of Sberbank Acquiring easier'
  spec.description   = 'This is an implementation of Sberbank Acuiring API client'
  spec.homepage      = 'https://github.com/panasyuk/sberbank-acquiring'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.require_paths = ['lib']
end
