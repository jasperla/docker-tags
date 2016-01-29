require 'bundler'
Bundler::GemHelper.install_tasks

desc "Open an irb session preloaded with this API"
task :console do
  $LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
  require 'dockertags'
  require 'irb'
  ARGV.clear
  IRB.start
end
