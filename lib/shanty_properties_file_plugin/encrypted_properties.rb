require 'gpgme'
require 'shanty_properties_file_plugin/properties'

module PropertiesFilePlugin
  # Public: properties class for getting environment config from properties files
  class EncryptedProperties < Properties
    # Public: initialize the properties class
    #
    # project_path - path to the project directory
    # default_file - name of the default properties files
    # files        - properties files to be processed
    def initialize(project_path, default_file, files, passphrase)
      @project_path = project_path
      @default_file = default_file
      @files = files
      @passphrase = passphrase
      @crypto = GPGME::Crypto.new
    end

    private

    # Private: Load data from an encrypted properties file
    #
    # file - file to load data from
    #
    # Returns an array of lines in the file
    def load_data(file)
      return [] unless File.exist?(file)
      @crypto.decrypt(File.open(file, 'rb').read, password: @passphrase).to_s.each_line.to_a
    rescue GPGME::Error::NoData
      []
    end
  end
end
