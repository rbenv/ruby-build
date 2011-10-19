EXECUTABLE = File.expand_path('../../bin/ruby-build', __FILE__)

describe "ruby-build" do
  def run(cmd)
    output = `#{EXECUTABLE} #{cmd} 2>&1`
    raise "failed" unless $?.success?
    output
  end

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
