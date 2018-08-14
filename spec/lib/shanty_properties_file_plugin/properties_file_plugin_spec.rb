require 'active_support/core_ext/hash/indifferent_access'
require 'fileutils'
require 'spec_helper'
require 'shanty_properties_file_plugin/properties_file_plugin'
require 'shanty_properties_file_plugin/properties'

# Tests for properties file plugin
module PropertiesFilePlugin
  RSpec.describe(PropertiesFilePlugin) do
    include_context('with plugin')

    def file_path(file)
      File.join(project_path, 'build', "#{file}.syaml")
    end

    it('adds the properties file tag automatically') do
      expect(described_class.tags).to match_array([:propertiesfile])
    end

    it('adds option for the output dir') do
      expect(described_class).to add_config(:output_dir, 'build')
    end

    it('finds projects that have a default.properties') do
      expect(described_class).to provide_projects_containing('**/default.properties')
    end

    it('subscribes to the build event') do
      expect(described_class).to subscribe_to(:build).with(:on_build)
    end

    before(:each) do
      allow(project).to receive(:path) { project_path }
      allow(project).to receive(:config) { {} }
    end

    describe('#do_build') do
      GPGME::Engine.set_info(0, `which gpg`.strip, nil)

      let(:passphrase) { 'nic' }
      let(:crypto) { GPGME::Crypto.new }

      before(:each) do
        FileUtils.touch(File.join(project_path, 'default.properties'))
        File.write(File.join(project_path, 'test1.properties'), 'nic=copolla')
      end

      def read_file(file)
        YAML.load_file(file_path(file))
      end

      it('writes out yaml file and merges encrypted and plain properties') do
        allow(file_tree).to receive(:glob).with("#{project.path}/*.properties").and_return(
          [File.join(project_path, 'test1.properties')]
        )
        allow(file_tree).to receive(:glob).with("#{project.path}/*.gpg").and_return(
          [File.join(project_path, 'test1.gpg')]
        )

        File.open(File.join(project_path, 'test1.gpg'), 'wb') do |f|
          crypto.encrypt('nic=cage', symmetric: true, output: f, password: passphrase)
        end

        allow(env).to receive(:config) { HashWithIndifferentAccess.new(propertiesfile: { passphrase: passphrase }) }

        subject.on_build

        expect(read_file('combined')).to eql('test1' => { 'nic' => 'cage' })
        expect(read_file('plain')).to eql('test1' => { 'nic' => 'copolla' })
        expect(read_file('encrypted')).to eql('test1' => { 'nic' => 'cage' })
      end

      it('writes out yaml file to a custom dir') do
        allow(env).to receive(:config) { HashWithIndifferentAccess.new(propertiesfile: { output_dir: 'nic' }) }

        subject.on_build

        expect(File.exist?(File.join(project_path, 'nic', 'combined.syaml'))).to be(true)
      end
    end

    describe('#artifacts') do
      it('only produces one artifact') do
        expect(subject.artifacts.size).to eql(3)
        expect(subject.artifacts.map { |a| a.uri.path }).to match_array([file_path('combined'),
                                                                         file_path('plain'),
                                                                         file_path('encrypted')])
      end
    end
  end
end
