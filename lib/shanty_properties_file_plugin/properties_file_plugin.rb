require 'deep_merge'
require 'fileutils'
require 'shanty/plugin'
require 'shanty/artifact'
require 'shanty_properties_file_plugin/properties'
require 'shanty_properties_file_plugin/encrypted_properties'
require 'yaml'

module PropertiesFilePlugin
  # Public: Properties file plugin
  class PropertiesFilePlugin < Shanty::Plugin
    PROPERTIES = 'properties'
    GPG = 'gpg'
    DEFAULT = 'default'
    OUTPUT_EXTENSION = 'syaml'
    COMBINDED_FILE = "combined.#{OUTPUT_EXTENSION}"
    PLAIN_FILE = "plain.#{OUTPUT_EXTENSION}"
    ENCRYPTED_FILE = "encrypted.#{OUTPUT_EXTENSION}"

    subscribe :build, :on_build
    provides_projects_containing "**/#{DEFAULT}.#{PROPERTIES}"
    provides_config :output_dir, 'build'
    provides_config :passphrase
    description 'Uses properties files as a envrionment data source'

    def on_build
      plain = properties
      encrypted = encrypted_properties
      write(output_file(PLAIN_FILE), plain)
      write(output_file(ENCRYPTED_FILE), encrypted)
      write(output_file(COMBINDED_FILE), encrypted.deep_merge(plain))
    end

    def artifacts
      [Shanty::Artifact.new(OUTPUT_EXTENSION, self.class.name, URI("file://#{output_file(PLAIN_FILE)}")),
       Shanty::Artifact.new(OUTPUT_EXTENSION, self.class.name, URI("file://#{output_file(ENCRYPTED_FILE)}")),
       Shanty::Artifact.new(OUTPUT_EXTENSION, self.class.name, URI("file://#{output_file(COMBINDED_FILE)}"))]
    end

    private

    def write(file, props)
      FileUtils.mkdir_p(File.dirname(file))
      File.open(file, 'w') { |f| f.write props.to_yaml }
    end

    def properties
      Properties.new(project.path,
                     "#{DEFAULT}.#{PROPERTIES}",
                     find_files(PROPERTIES)).properties
    end

    def encrypted_properties
      EncryptedProperties.new(project.path,
                              "#{DEFAULT}.#{GPG}",
                              find_files(GPG),
                              config[:passphrase]).properties
    end

    def find_files(extenstion)
      env.file_tree.glob("#{project.path}/*.#{extenstion}").reject do |v|
        v.include?("#{DEFAULT}.#{extenstion}")
      end
    end

    def output_file(file)
      File.join(project.path, config[:output_dir], file)
    end
  end
end
