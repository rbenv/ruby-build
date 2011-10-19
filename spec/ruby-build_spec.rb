EXECUTABLE = File.expand_path('../../bin/ruby-build', __FILE__)

describe "ruby-build" do
  def run(cmd)
    output = `#{EXECUTABLE} #{cmd} 2>&1`
    raise "failed" unless $?.success?
    output
  end

  describe "commandline interface" do
    it "shows help via --help" do
      run("--help").should include('List all built-in definitions')
    end

    it "shows help via -h" do
      run("-h").should include('List all built-in definitions')
    end

    it "shows version" do
      run("--version").should =~ /^ruby-build \d+$/m
    end
  end

  describe "list_definitions" do
    it "shows all ruby versions" do
      results = run("--test list_definitions").split(' ')
      results.size.should > 10
      results.first.should == "1.8.6-p420"
      results.last.should == "ree-1.8.7-2011.03"
    end
  end
end
