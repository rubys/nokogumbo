require 'rubygems/package_task'
require 'rake/clean'
require 'rake/extensiontask'
require 'rake/testtask'

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nokogumbo/version'

# default to running tests
task default: :test
task test: :compile
task gem: :test

ext = Rake::ExtensionTask.new 'nokogumbo' do |e|
  e.lib_dir = 'lib/nokogumbo'
  e.source_pattern = '../../gumbo-parser/src/*.[hc]'
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/test_*.rb']
end

# list of ext source files to be included in package, excluded from CLEAN
SOURCES = Dir['ext/nokogumbo/*.{rb,c}']

desc 'Run the gumbo unit tests'
task 'test:gumbo' => 'gumbo-parser/googletest' do
  sh('make', '-j2', '-C', 'gumbo-parser')
end

desc 'Start a console'
task console: :compile do
  sh('irb', '-Ilib', '-rnokogumbo')
end

Gem::PackageTask.new(Gem::Specification.load('nokogumbo.gemspec')) do |pkg|
  pkg.need_tar = true
  pkg.need_zip = true
end

# cleanup
CLEAN.include(FileList.new('ext/nokogumbo/*') - SOURCES)
CLEAN.include(File.join('lib/nokogumbo', ext.binary))
CLOBBER.include(FileList.new('pkg', 'Gemfile.lock'))

# silence cleanup operations
Rake::Task[:clobber_package].clear
CLEAN.existing!
CLOBBER.existing!.uniq!
