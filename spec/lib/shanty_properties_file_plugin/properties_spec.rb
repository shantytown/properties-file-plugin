require 'fileutils'
require 'shanty_properties_file_plugin/properties'
require 'yaml'
require 'spec_helper'

# Tests for properties class
module PropertiesFilePlugin
  RSpec.describe(Properties) do
    include_context('properties')

    let(:default_file) { 'default.properties' }
    subject { described_class.new(project_path, default_file, files) }

    describe('#properties') do
      it('outputs nothing when there are no input files or defaults') do
        expect(subject.properties).to be_empty
      end

      it('outputs nothing when defaults file exits, but no environments are defined') do
        File.open(File.join(project_path, default_file), 'w') { |f| f.write('foo=bar') }

        expect(subject.properties).to be_empty
      end

      it('skips over a malformed line') do
        File.open(File.join(project_path, 'test1.properties'), 'w') { |f| f.write('nic cage is the best') }

        expect(subject.properties).to be_empty
      end

      it('skips over commented lines') do
        File.open(File.join(project_path, 'test1.properties'), 'w') { |f| f.write('#nic=cage') }

        expect(subject.properties).to be_empty
      end
    end

    describe('#properties') do
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
        expect(subject.properties).to eql(no_defaults)
      end

      it('reads defaults and adds them to each environment') do
        File.open(File.join(project_path, default_file), 'w') { |f| f.write('foo=bar') }

        expect(subject.properties).to eql(no_defaults.each { |_, v| v['foo'] = 'bar' })
      end

      it('can override defaults in each environment') do
        File.open(File.join(project_path, default_file), 'w') { |f| f.write('nic=kim') }

        expect(subject.properties).to eql(no_defaults.merge('test3' => { 'nic' => 'kim' }))
      end
    end
  end
end
