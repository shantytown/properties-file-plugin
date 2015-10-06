module PropertiesFilePlugin
  # Public: properties class for getting environment config from properties files
  class Properties
    # Public: initialize the properties class
    #
    # project_path - path to the project directory
    # default_file - name of the default properties files
    # files        - properties files to be processed
    def initialize(project_path, default_file, files)
      @project_path = project_path
      @default_file = default_file
      @files = files
    end

    # Public: extract properties from each file and merge with defaults
    #
    # Returns a hash of envrionments with properties
    def properties
      @files.each_with_object({}) do |file, acc|
        acc[environment(file)] = defaults.merge(load_properties(file))
      end
    end

    private

    # Private: Load data from a properties file
    #
    # file - file to load data from
    #
    # Returns an array of lines in the file
    def load_data(file)
      return [] unless File.exist?(file)
      File.open(file, 'rb').read.each_line.to_a
    end

    # Private: load the default properties
    #
    # Returns a hash of defaults if the file exits, otherwise an empty hash
    def defaults
      @defaults ||= load_properties(File.join(@project_path, @default_file))
    rescue
      @defaults ||= {}
    end

    # Private load properties from a file
    #
    # file - the properties file to load data from
    #
    # Returns a hash of properties
    def load_properties(file)
      read_properties(load_data(file))
    end

    # Private: Get the environment from the properties file name
    #
    # file - Name of the properties file from which to
    #        extract the environment name.
    #
    # Returns a string of the environment name
    def environment(file)
      File.basename(file).split('.').first
    end

    # Private: Format the property value.
    #
    # value - Value string to format.
    #
    # Returns the formatted value.
    def format(value)
      value.delete('\'').delete('"')
    end

    # Private: read properties from a data set
    #
    # data - array of properties data
    #
    # Returns a hash of properties
    def read_properties(data)
      data.each_with_object({}) do |line, acc|
        key, value = line.strip.split('=', 2)
        acc[key] = format(value || '')
      end
    end
  end
end
