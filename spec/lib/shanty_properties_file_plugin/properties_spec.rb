require 'fileutils'
require 'shanty_properties_file_plugin/properties'
require 'yaml'

# Tests for properties class
module PropertiesFilePlugin
  RSpec.describe(Properties) do
    let(:project_path) { Dir.mktmpdir }
    let(:project) { project_class.new(project_path) }
    let(:output_file) { File.join(project_path, 'out', 'test.yaml') }
    let(:files) { [] }
    let(:default_file) { 'default.properties' }
    subject { described_class.new(project_path, default_file, files, output_file) }

    after(:each) do
      FileUtils.rm_rf(project_path)
    end

    describe('#write!') do
      it('outputs nothing when there are no input files or defaults') do
        subject.write!

        expect(YAML.load_file(output_file)).to be_empty
      end

      it('outputs nothing when defaults file exits, but no environments are defined') do
        File.open(File.join(project_path, default_file), 'w') { |f| f.write('foo=bar') }

        subject.write!

        expect(YAML.load_file(output_file)).to be_empty
      end

      it('skips over a malformed line') do
        File.open(File.join(project_path, 'test1.properties'), 'w') { |f| f.write('nic cage is the best') }

        subject.write!

        expect(YAML.load_file(output_file)).to be_empty
      end

      it('skips over commented lines') do
        File.open(File.join(project_path, 'test1.properties'), 'w') { |f| f.write('#nic=cage') }

        subject.write!

        expect(YAML.load_file(output_file)).to be_empty
      end
    end

    describe('#write!') do
      before(:each) do
        File.open(File.join(project_path, 'test1.properties'), 'w') { |f| f.write('nic=copolla') }
        File.open(File.join(project_path, 'test2.properties'), 'w') { |f| f.write('nic=cage') }
        FileUtils.touch(File.join(project_path, 'test3.properties'))
      end

      let(:files) do
        [File.join(project_path, 'test1.properties'),
         File.join(project_path, 'test2.properties'),
         File.join(project_path, 'test3.properties')]
      end

      let(:no_defaults) do
        { 'test1' => { 'nic' => 'copolla' },
          'test2' => { 'nic' => 'cage' },
          'test3' => {} }
      end

      it('reads properties files when there are no defaults') do
        subject.write!

        expect(YAML.load_file(output_file)).to eql(no_defaults)
      end

      it('reads defaults and adds them to each environment') do
        File.open(File.join(project_path, default_file), 'w') { |f| f.write('foo=bar') }

        subject.write!

        expect(YAML.load_file(output_file)).to eql(no_defaults.each { |_, v| v['foo'] = 'bar' })
      end

      it('can override defaults in each environment') do
        File.open(File.join(project_path, default_file), 'w') { |f| f.write('nic=kim') }

        subject.write!

        expect(YAML.load_file(output_file)).to eql(no_defaults.merge('test3' => { 'nic' => 'kim' }))
      end
    end
  end
end
