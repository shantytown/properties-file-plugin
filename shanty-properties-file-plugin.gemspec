Gem::Specification.new do |gem|
  gem.name = 'shanty-properties-file-plugin'
  gem.version = '0.2.0'
  gem.homepage = 'https://github.com/shanty/properties-file-plugin'
  gem.license = 'MIT'

  gem.author = 'Chris Jansen'
  gem.email = 'chris.jansen@intenthq.comm'
  gem.summary = 'Properties file plugin for Shanty.'
  gem.description = "See #{gem.homepage} for more information!"

  # Uncomment this if you plan on having an executable instead of a library.
  # gem.executables << 'your_wonderful_gem'
  gem.files = Dir['**/*'].select { |d| d =~ %r{^(README.md|bin/|ext/|lib/)} }

  # Add your dependencies here as follows:
  #
  #   gem.add_dependency 'some-gem', '~> 1.0'

  # Add your test dependencies here as follows:
  #
  #   gem.add_development_dependency 'whatever', '~> 1.0'
  #
  # Some sane defaults follow.
  gem.add_dependency 'deep_merge', '~>1.2.1'
  gem.add_dependency 'gpgme', '~> 2.0.16'

  gem.add_development_dependency 'coveralls', '~>0.8'
  gem.add_development_dependency 'filewatcher', '~>1.0'
  gem.add_development_dependency 'pry-byebug', '~>3.6'
  gem.add_development_dependency 'rspec', '~>3.8'
  gem.add_development_dependency 'rubocop', '~>0.58'
  gem.add_development_dependency 'rubocop-rspec', '~>1.27'
end
