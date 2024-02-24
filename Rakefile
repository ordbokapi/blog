require 'rake'
require 'date'
require 'fileutils'
require 'open-uri'
require 'json'
require 'yaml'
require 'net/http'
require 'optparse'
require 'tzinfo'

def slugify(title)
  slug = title.downcase
    .gsub(/\s+|_/, '-')
    .gsub(/[^a-z0-9\-]/, '')
    .gsub(/^-|-$/, '')
  slug
end

configuredTimezone = YAML.load_file('_config.yml')['timezone']
timezone = TZInfo::Timezone.get(configuredTimezone)

task :default => [:install, :serve, :build]

desc 'Install dependencies using Bundler'
task :install do
  sh 'bundle install'
  sh 'rake postinstall'
end

desc 'Post install tasks'
task :postinstall do
  # Copy bootstrap files

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
  open('assets/js/lunr.js', 'wb') do |file|
    file << URI.open('https://unpkg.com/lunr/lunr.min.js').read
  end
end

desc 'Notify about new posts'
task :notify_new_post do
  api_key = ENV['API_KEY']

  if api_key.nil?
    # try reading from secrets.yml
    begin
      secrets = YAML.load_file('secrets.yml')
      api_key = secrets['apiKey']
    rescue
    end
  end

  if api_key.nil?
    puts 'API_KEY is not set, not notifying'
    exit 1
  end

  if !File.exist?('new_post.json')
    puts 'No new post was created'
    exit 0
  end

  new_post_raw = File.read('new_post.json')

  if new_post_raw.nil?
    puts 'Failed to read new_post.json'
    exit 1
  end

  new_post = JSON.parse(new_post_raw)

  required_props = ['title', 'url', 'summary']

  if required_props.any? { |prop| new_post[prop].nil? }
    puts 'new_post.json is missing one or more required properties: ' + required_props.join(', ')
    exit 1
  end

  # safety check so we don't send accidentally notify about old posts
  # if the latest post is not from within the last 24 hours, don't notify
  if DateTime.parse(new_post['date']).to_time.utc < Time.now.utc - 24 * 60 * 60
    puts 'Latest post is older than 24 hours, not notifying'
    exit 0
  end

  puts 'Notifying about new post'
  puts new_post

  # Send POST to https://blog-api.ordbokapi.org/new-post
  # The API server expects a JSON body like this:
  # {
  #   "title": "New post title",
  #   "url": "https://blog.ordbokapi.org/2020/01/01/new-post.html",
  #   "summary": "A short summary of the new post"
  # }
  # The API server will respond with a 202 Accepted status code if the request is successful.
  # The API key is expected to be passed in the Authorization header.

  # read api server url from _data/api.yml (baseUrl)

  api_config = YAML.load_file('_data/api.yml')
  api_url = api_config['baseUrl'] + '/new-post'
  uri = URI.parse(api_url)

  http = Net::HTTP.new(uri.host, uri.port)

  if uri.scheme == 'https'
    http.use_ssl = true
  end

  request = Net::HTTP::Post.new(uri.request_uri)
  request['Authorization'] = api_key
  request['Content-Type'] = 'application/json'
  request.body = JSON.generate({
    title: new_post['title'],
    url: new_post['url'],
    summary: new_post['summary']
  })

  response = http.request(request)

  if response.code == '202'
    puts 'Notification sent successfully'
  else
    puts 'Failed to send notification'
    puts response.code
    puts response.body
    exit 1
  end
end

desc 'Start the Jekyll server'
task :serve do
  sh 'bundle exec jekyll serve --drafts --livereload'
end

desc 'Build the site'
task :build do
  sh 'bundle exec jekyll build'
end

namespace :draft do |args|
  desc 'Create a new draft'
  task :new do
    title = nil

    OptionParser.new do |opts|
      opts.banner = "Usage: rake draft:new -- -t 'Draft title'"
      opts.on("-t", "--title TITLE", "Title of the draft") do |t|
        title = t
      end

      args = opts.order!(ARGV) {}
      opts.parse!(args)
    end

    if title.nil?
      puts 'No title specified'
      exit 1
    end

    filename = "_drafts/#{slugify(title)}.md"
    if File.exist?(filename)
      puts 'File already exists'
      exit 1
    end

    FileUtils.mkdir_p('_drafts')
    File.open(filename, 'w') do |file|
      file.write("---\n")
      file.write("layout: post\n")
      file.write("title: \"#{title}\"\n")
      file.write("date: #{DateTime.now.strftime('%Y-%m-%d %H:%M:%S %z')}\n")
      file.write("author: \n")
      file.write("image: \n")
      file.write("categories: \n")
      file.write("summary: \"\"\n")
      file.write("---\n")
    end

    FileUtils.mkdir_p("assets/attachments/drafts/#{slugify(title)}")

    puts "Created new draft: #{filename}"
    exit 0
  end

  desc 'Publish a draft or all drafts'
  task :publish do
    options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: rake draft:publish -- [options]"

      opts.on("-t", "--title TITLE", "Title of the draft to publish") do |t|
        options[:title] = t
      end

      opts.on("-a", "--all", "Publish all drafts") do |a|
        options[:all] = a
      end

      args = opts.order!(ARGV) {}
      opts.parse!(args)
    end

    publish_draft = lambda do |title|
      slug = title.downcase.strip.gsub(' ', '-')
      draft_filename = "_drafts/#{slug}.md"
      if !File.exist?(draft_filename)
        puts "Draft not found: #{draft_filename}"
        return
      end

      now = DateTime.now

      utcDate = now.new_offset(0)
      localDate = timezone.utc_to_local(utcDate)
      date = localDate.strftime('%Y-%m-%d')

      filename = "_posts/#{date}-#{slug}.md"
      if File.exist?(filename)
        puts "Post already exists: #{filename}"
        return
      end

      FileUtils.mv(draft_filename, filename)
      content = File.read(filename)
      content = content.sub(/date: .*/, "date: #{now.strftime('%Y-%m-%d %H:%M:%S %z')}")
      File.open(filename, 'w') { |file| file.puts content }

      draft_attachments_dir = "assets/attachments/drafts/#{slug}"
      post_attachments_dir = "assets/attachments/#{now.strftime('%Y/%m/%d')}/#{slug}"
      if Dir.exist?(draft_attachments_dir)
        # only move the files if the post has attachments
        if Dir.glob("#{draft_attachments_dir}/*").length > 0
          FileUtils.mkdir_p(post_attachments_dir)
          FileUtils.mv(Dir.glob("#{draft_attachments_dir}/*"), post_attachments_dir)
        end

        FileUtils.remove_dir(draft_attachments_dir)
      end

      puts "Published draft: #{filename}"
    end

    if options[:all]
      drafts = Dir.glob('_drafts/*.md')
      drafts.each do |draft|
        title = File.basename(draft, '.md')
        publish_draft.call(title)
      end
    elsif options[:title]
      publish_draft.call(options[:title])
    else
      puts 'Error: No title specified and --all not set. Use --title to specify a draft or --all to publish all drafts.'
      exit 1
    end

    exit 0
  end
end

desc 'Get a timestamp suitable for post front matter'
task :timestamp do
  puts DateTime.now.strftime('%Y-%m-%d %H:%M:%S %z')
end
