require 'rake'

task :default => [:install, :serve, :build]

desc 'Install dependencies using Bundler'
task :install do
  sh 'bundle install'
  sh 'rake postinstall'
end

desc 'Post install tasks'
task :postinstall do
  # Copy bootstrap files

  require 'fileutils'

  bootstrap_gem_path = `bundle show bootstrap`.strip
  sass_target_path = '_sass/bootstrap'
  js_target_path = 'assets/js/bootstrap'

  FileUtils.rm_rf(sass_target_path)
  FileUtils.rm_rf(js_target_path)

  FileUtils.mkdir_p(sass_target_path)
  FileUtils.mkdir_p(js_target_path)

  FileUtils.cp_r(Dir.glob("#{bootstrap_gem_path}/assets/stylesheets/*"), sass_target_path)
  FileUtils.cp_r(Dir.glob("#{bootstrap_gem_path}/assets/javascripts/*"), js_target_path)

  # Download lunr.js from https://unpkg.com/lunr/lunr.js and save it to assets/js/lunr.js
  require 'open-uri'

  open('assets/js/lunr.js', 'wb') do |file|
    file << URI.open('https://unpkg.com/lunr/lunr.min.js').read
  end
end

desc 'Start the Jekyll server'
task :serve do
  sh 'bundle exec jekyll serve'
end

desc 'Build the site'
task :build do
  sh 'bundle exec jekyll build'
end
