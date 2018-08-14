RSpec.shared_context('with properties') do
  let(:project_path) { Dir.mktmpdir }
  let(:project) { project_class.new(project_path) }
  let(:files) { [] }

  after(:each) do
    FileUtils.rm_rf(project_path)
  end
end
