module Jekyll
  class LunrIndexGenerator < Generator
    safe true
    priority :low

    def generate(site)
      puts "Jekyll Lunr Index Generator: Generating search index"

      lunr_documents = []
      counter = 0

      # Combine pages, posts, and any other collections
      all_documents = site.pages + site.posts.docs

      # Add any other collections, checking if they exist
      site.collections.each do |name, collection|
        next if ['pages', 'posts'].include?(name) # Already included above
        all_documents += collection.docs
      end

      all_documents.each do |doc|
        next if doc.url.include?('.xml') || doc.url.include?('assets')

        # Exclude 404 page
        next if doc.url.end_with?('404.html')

        # Prepare document data for JSON
        document = {
          id: counter,
          url: site.baseurl + doc.url,
          title: doc.data['title'] || '',
          body: prepare_content(doc)
        }

        next if document[:body].empty?

        lunr_documents << document
        counter += 1
      end

      # Write to a JSON file in the site source directory
      write_path = File.join('search_index.json')
      puts "Writing search index to " + write_path
      File.open(write_path, 'w') do |file|
        file.write(JSON.pretty_generate(lunr_documents))
      end

      site.static_files << Jekyll::StaticFile.new(site, site.source, '', 'search_index.json')
    end

    private

    def prepare_content(doc)
      content = doc.content
      content = content
        .gsub(/<\/h[2-4]\s*>/, ': ')
        .gsub('</p>', ' ')
        .strip
        .gsub(/<.*?>/, '')
        .gsub(/\s+/, ' ')
        .gsub('"', '\"')
      content
    end
  end
end
