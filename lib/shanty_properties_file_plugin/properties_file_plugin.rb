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

    option :output_dir, 'build'
    subscribe :build, :on_build
    projects "**/#{DEFAULT}.#{PROPERTIES}"

    def on_build(project)
      plain = properties(project)
      encrypted = encrypted_properties(project)
      write(output_file(project, PLAIN_FILE), plain)
      write(output_file(project, ENCRYPTED_FILE), encrypted)
      write(output_file(project, COMBINDED_FILE), encrypted.deep_merge(plain))
    end

    def artifacts(project)
      [Shanty::Artifact.new(OUTPUT_EXTENSION, self.class.name, URI("file://#{output_file(project, PLAIN_FILE)}")),
       Shanty::Artifact.new(OUTPUT_EXTENSION, self.class.name, URI("file://#{output_file(project, ENCRYPTED_FILE)}")),
       Shanty::Artifact.new(OUTPUT_EXTENSION, self.class.name, URI("file://#{output_file(project, COMBINDED_FILE)}"))]
    end

    private

    def write(file, props)
      FileUtils.mkdir_p(File.dirname(file))
      File.open(file, 'w') { |f| f.write props.to_yaml }
    end

    def properties(project)
      Properties.new(project.path,
                     "#{DEFAULT}.#{PROPERTIES}",
                     find_files(project, PROPERTIES)).properties
    end

    def encrypted_properties(project)
      EncryptedProperties.new(project.path,
                              "#{DEFAULT}.#{GPG}",
                              find_files(project, GPG),
                              self.class.options.passphrase).properties
    end

    def find_files(project, extenstion)
      project_tree.glob("#{project.path}/*.#{extenstion}").keep_if do |v|
        !v.include?("#{DEFAULT}.#{extenstion}")
      end
    end

    def output_file(project, file)
      File.join(project.path, self.class.options.output_dir, file)
    end
  end
end
