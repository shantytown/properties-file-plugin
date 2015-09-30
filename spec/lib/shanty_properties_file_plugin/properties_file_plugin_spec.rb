require 'fileutils'
require 'spec_helper'
require 'shanty_properties_file_plugin/properties_file_plugin'
require 'shanty_properties_file_plugin/properties'

# Tests for properties file plugin
module PropertiesFilePlugin
  RSpec.describe(PropertiesFilePlugin) do
    include_context('graph')

    def file_path(file)
      File.join(root, 'one', 'build', "#{file}.syaml")
    end

    it('adds the properties file tag automatically') do
      expect(described_class.tags).to match_array([:propertiesfile])
    end

    it('adds option for the output dir') do
      expect(described_class).to add_option(:output_dir, 'build')
    end

    it('finds projects that have a default.properties') do
      expect(described_class).to define_projects.with('**/default.properties')
    end

    it('subscribes to the build event') do
      expect(described_class).to subscribe_to(:build).with(:on_build)
    end

    describe('#do_build') do
      GPGME::Engine.set_info(0, `which gpg`.strip, nil)

      let(:passphrase) { 'nic' }
      let(:crypto) { GPGME::Crypto.new }

      before(:each) do
        FileUtils.touch(File.join(root, 'one', 'default.properties'))
        File.open(File.join(root, 'one', 'test1.properties'), 'w') { |f| f.write('nic=copolla') }
      end

      def read_file(file)
        YAML.load_file(file_path(file))
      end

      it('writes out yaml file and merges encrypted and plain properties') do
        File.open(File.join(root, 'one', 'test1.gpg'), 'wb') do |f|
          crypto.encrypt('nic=cage', symmetric: true, output: f, password: passphrase)
        end

        allow(YAML).to receive(:load_file) { { 'local' => { 'propertiesfile' => { 'passphrase' => passphrase } } } }

        subject.on_build(project)

        allow(YAML).to receive(:load_file).and_call_original

        expect(read_file('combined')).to eql('test1' => { 'nic' => 'cage' })
        expect(read_file('plain')).to eql('test1' => { 'nic' => 'copolla' })
        expect(read_file('encrypted')).to eql('test1' => { 'nic' => 'cage' })
      end

      it('writes out yaml file to a custom dir') do
        allow(YAML).to receive(:load_file) { { 'local' => { 'propertiesfile' => { 'output_dir' => 'nic' } } } }

        subject.on_build(project)

        expect(File.exist?(File.join(root, 'one', 'nic', 'combined.syaml'))).to be(true)
      end
    end

    describe('#artifacts') do
      it('only produces one artifact') do
        expect(subject.artifacts(project).size).to eql(3)
        expect(subject.artifacts(project).map { |a| a.uri.path }).to match_array([file_path('combined'),
                                                                                  file_path('plain'),
                                                                                  file_path('encrypted')])
      end
    end
  end
end
