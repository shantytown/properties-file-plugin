require 'fileutils'
require 'gpgme'
require 'shanty_properties_file_plugin/encrypted_properties'
require 'spec_helper'

# Tests for properties class
module PropertiesFilePlugin
  RSpec.describe(EncryptedProperties) do
    include_context('with properties')

    # Set GPG engine to GPG v1 for testing to stop interactive pin enty
    GPGME::Engine.set_info(0, `which gpg`.strip, nil)

    let(:passphrase) { 'nic' }
    let(:default_file) { 'default.gpg' }
    let(:crypto) { GPGME::Crypto.new }

    subject { described_class.new(project_path, default_file, files, passphrase) }

    describe('#properties') do
      before(:each) do
        File.open(File.join(project_path, 'test1.gpg'), 'wb') do |f|
          crypto.encrypt('nic=copolla', symmetric: true, output: f, password: passphrase)
        end
      end

      let(:files) do
        [File.join(project_path, 'test1.gpg')]
      end

      it('can decrypt properties from a file') do
        expect(subject.properties).to eql('test1' => { 'nic' => 'copolla' })
      end

      it('fails to decrypt properties when passphrase is invalid') do
        File.open(File.join(project_path, 'test1.gpg'), 'wb') do |f|
          crypto.encrypt('nic=copolla', symmetric: true, output: f, password: 'cage')
        end

        expect { subject.properties }.to raise_error(GPGME::Error::DecryptFailed)
      end
    end
  end
end
