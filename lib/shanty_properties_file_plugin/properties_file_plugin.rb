require 'shanty/plugin'
require 'shanty/artifact'
require 'shanty_properties_file_plugin/properties'
require 'yaml'

module PropertiesFilePlugin
  # Public: Properties file plugin
  class PropertiesFilePlugin < Shanty::Plugin
    DEFAULT_PROPERTIES = 'default.properties'
    OUTPUT_EXTENSION = 'syaml'
    OUTPUT_FILE = "output.#{OUTPUT_EXTENSION}"

    option :outputdir, 'build'
    subscribe :build, :on_build
    projects "**/#{DEFAULT_PROPERTIES}"

    def on_build(project)
      files = project_tree.glob("#{project.path}/*.properties").keep_if { |v| v.include?(DEFAULT_PROPERTIES) }
      Properties.new(project,
                     DEFAULT_PROPERTIES,
                     files,
                     output_file(project)).write!
    end

    def artifacts(project)
      [Shanty::Artifact.new(OUTPUT_EXTENSION, self.class.name, URI("file://#{output_file(project)}"))]
    end

    private

    def output_file(project)
      File.join(project.path, self.class.options.outputdir, OUTPUT_FILE)
    end
  end
end
