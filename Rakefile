require 'rake/clean'
require 'rake/testtask'
require 'fileutils'

require "rake/gempackagetask"

task :default => :package

# PACKAGING ============================================================

# Load the gemspec using the same limitations as github
def spec
  @spec ||=
    begin
      require 'rubygems/specification'
      data = File.read('pdbook.gemspec')
      spec = nil
      Thread.new { spec = eval("$SAFE = 3\n#{data}") }.join
      spec
    end
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Install the Pdbook as a gem"
task :install => [:repackage] do
  sh %{gem install pkg/#{spec.name}-#{spec.version}}
end

# Gemspec Helpers ====================================================

def source_version
  line = File.read('lib/pdbook.rb')[/^\s*VERSION = .*/]
  line.match(/.*VERSION = '(.*)'/)[1]
end

task 'pdbook.gemspec' => FileList['lib/**','bin/**','Rakefile','LICENSE','README'] do |f|
  # read spec file and split out manifest section
  spec = File.read(f.name)
  head, manifest, tail = spec.split("  # = MANIFEST =\n")
  # replace version and date
  head.sub!(/\.version = '.*'/, ".version = '#{source_version}'")
  head.sub!(/\.date = '.*'/, ".date = '#{Date.today.to_s}'")
  # determine file list from git ls-files
  files = `git ls-files`.
    split("\n").
    sort.
    reject{ |file| file =~ /^\./ }.
    reject { |file| file =~ /^doc/ }.
    map{ |file| "    #{file}" }.
    join("\n")
  # piece file back together and write...
  manifest = "  s.files = %w[\n#{files}\n  ]\n"
  spec = [head,manifest,tail].join("  # = MANIFEST =\n")
  File.open(f.name, 'w') { |io| io.write(spec) }
  puts "updated #{f.name}"
end
