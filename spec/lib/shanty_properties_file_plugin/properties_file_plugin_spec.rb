require 'fileutils'
require 'spec_helper'
require 'shanty_properties_file_plugin/properties_file_plugin'

# Tests for properties file plugin
module PropertiesFilePlugin
  RSpec.describe(PropertiesFilePlugin) do
    include_context('graph')

    it('adds the properties file tag automatically') do
      expect(described_class.tags).to match_array([:propertiesfile])
    end

    it('adds option for the output dir') do
      expect(described_class).to add_option(:outputdir, 'build')
    end

    it('finds projects that have a default.properties') do
      expect(described_class).to define_projects.with('**/default.properties')
    end

    it('subscribes to the build event') do
      expect(described_class).to subscribe_to(:build).with(:on_build)
    end

    describe('#do_build') do
      before(:each) do
        FileUtils.mkdir_p(File.join(root, 'one'))
        FileUtils.touch(File.join(root, 'one', 'default.properties'))
        FileUtils.touch(File.join(root, 'one', 'test1.properties'))
      end

      it('writes out yaml file') do
        subject.on_build(project)

        expect(File.exist?(File.join(root, 'one', 'build', 'output.syaml'))).to be(true)
      end

      it('writes out yaml file to a customer dir') do
        allow(YAML).to receive(:load_file) { { 'local' => { 'propertiesfile' => { 'outputdir' => 'nic' } } } }

        subject.on_build(project)

        expect(File.exist?(File.join(root, 'one', 'nic', 'output.syaml'))).to be(true)
      end
    end

    describe('#artifacts') do
      it('only produces one artifact') do
        expect(subject.artifacts(project).size).to eql(1)
        expect(subject.artifacts(project).first.uri.path).to eql(File.join(root, 'one', 'build', 'output.syaml'))
      end
    end
  end
end
