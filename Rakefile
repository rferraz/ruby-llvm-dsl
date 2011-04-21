require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
begin
  require 'rcov/rcovtask'
rescue LoadError
  warn "Proceeding without Rcov. gem install rcov on supported platforms."
end

Rake::RDocTask.new do |t|
  t.rdoc_files   = Dir['lib/**/*.rb']
end

def spec
  Gem::Specification.new do |s|
    s.platform = Gem::Platform::RUBY
    
    s.name = 'ruby-llvm-dsl'
    s.version = '2.9.0'
    s.summary = "LLVM bindings for Ruby"
    
    s.add_dependency('ruby-llvm', '= 2.9.0')
    s.files = Dir['lib/**/*rb']
    s.require_path = 'lib'
    
    s.has_rdoc = true
    s.extra_rdoc_files = 'README.rdoc'
    
    s.author = "Ronaldo M. Ferraz"
    s.email = "ronaldoferraz@gmail.com"
    s.homepage = "http://github.com/rferraz/ruby-llvm-dsl"
  end
end

Rake::GemPackageTask.new(spec) do |t|
end

if defined?(Rcov)
  Rcov::RcovTask.new do |t|
    t.libs << "test"
    t.rcov_opts << "--exclude gems"
    t.test_files = FileList["test/**/*_test.rb"]
  end
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => [:test]
