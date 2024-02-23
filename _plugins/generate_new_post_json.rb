require 'json'

module Jekyll
  class LatestPostGenerator < Generator
    safe true
    priority :low

    def generate(site)
      puts "Jekyll New Post JSON Generator: Checking for new posts"

      begin
        File.delete('new_post.json')
      rescue
      end

      # Check for new files in the last commit in the _posts directory
      changed_files = `git diff-tree --no-commit-id --name-status -r HEAD`.lines
      new_posts = changed_files.select { |line| line.start_with?('A') && line.include?('_posts/') }

      if new_posts.empty?
        puts 'No new post was created'
        return
      end

      # map the new posts to their jekyll data
      new_posts = new_posts.map do |line|
        file = line.split("\t").last.strip
        post = site.posts.docs.find { |p| p.relative_path == file }

        if post.nil?
          next
        end

        {
          title: post.data['title'],
          date: post.date,
          author: site.data['authors'][post.data['author']],
          url: site.config['url'] + post.url,
          summary: post.data['summary']
        }
      end
      new_posts = new_posts.compact

      new_post = new_posts.max_by { |post| post[:date] }

      # safety check so we don't send accidentally notify about old posts
      # if the latest post is not from within the last 24 hours, don't notify
      if new_post[:date] < Time.now - 24 * 60 * 60
        puts 'Latest post is older than 24 hours, not notifying'
        return
      end

      # Write to a JSON file in the repository root
      write_path = File.join('new_post.json')
      File.open(write_path, 'w') do |file|
        file.write(JSON.pretty_generate(new_post))
      end
    end
  end
end
