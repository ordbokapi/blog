module Jekyll
  class FileExistsTag < Liquid::Tag
    def initialize(tag_name, path, tokens)
      super
      @path = path
    end

    def render(context)
      url = Liquid::Template.parse(@path).render(context)
      site_source = context.registers[:site].config['source']
      file_path = File.join(site_source, url.strip)

      "#{File.exist?(file_path)}"
    end
  end

  # Filter which allows specifying an alternate file path if the one piped to it
  # does not exist.
  # Example usage:
  #   {{ 'file.txt' | fallback_path: 'file2.txt' }}
  module FallbackPathFilter
    def fallback_path(input, fallback)
      if input.nil? || input.empty?
        return fallback
      end

      site_source = @context.registers[:site].config['source']
      file_path = File.join(site_source, input.strip)

      if File.exist?(file_path)
        input
      else
        fallback
      end
    end
  end

  Liquid::Template.register_tag('file_exists', FileExistsTag)
  Liquid::Template.register_filter(FallbackPathFilter)
end

