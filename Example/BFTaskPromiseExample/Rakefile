require 'xcjobs'

XCJobs::Test.new('test') do |t|
  t.build_dir = 'build'
  t.workspace = 'BFTaskPromiseExample'
  t.scheme = 'BFTaskPromiseExample'
  t.configuration = 'Release'
  t.add_destination('platform=iOS Simulator,name=iPad Air,OS=8.1')
  t.formatter = 'xcpretty -c'
  t.coverage = true
end

XCJobs::Coverage::Coveralls.new() do |t|
  t.add_extension('.m')
  t.add_exclude('Example/BFTaskPromiseExample/BFTaskPromiseExample')
  t.add_exclude('Example/BFTaskPromiseExample/BFTaskPromiseExampleTests')
end
