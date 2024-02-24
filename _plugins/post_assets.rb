# Liquid tag to refer to a file in the asset directory of a post.
# For a published post, this is the directory
#   assets/attachments/<year>/<month>/<day>/<post-slug>/
# For a draft, it is:
#   assets/attachments/drafts/<post-slug>/

module Jekyll
  # example usage to get the post's asset directory:
  # {% post_asset_dir %}
  # or when not in a post context:
  # {% post_asset_dir jekyll_post_object %}
  class PostAssetDirTag < Liquid::Tag
    def initialize(tag_name, input, tokens)
      super
      @input = input.strip
    end

    def render(context)
      if @input.empty?
        post = context['page']
      else
        post = context[@input]
      end
      raise 'Could not find post' unless post

      # For a published post
      if post['published']
        "/assets/attachments/#{post['date'].strftime('%Y/%m/%d')}/#{post['slug']}/"
      else
        # For a draft
        "/assets/attachments/drafts/#{post['slug']}/"
      end
    end
  end

  # example usage to refer to a specific file in the post's asset directory:
  # {% 'file.txt' | post_asset_path %}
  # or when not in a post context:
  # {% 'file.txt' | post_asset_path: jekyll_post_object %}
  module PostAssetPathFilter
    def post_asset_path(filename, post = nil)
      if filename.nil? || filename.empty?
        return filename
      end

      # Retrieve the current post's data if not explicitly provided
      post = @context.registers[:page] unless post

      raise 'Could not find post data' unless post

      # Determine the asset path based on whether the post is published or a draft
      asset_path = if post['published']
        "assets/attachments/#{post['date'].strftime('%Y/%m/%d')}/#{post['slug']}"
      else
        "assets/attachments/drafts/#{post['slug']}"
      end

      # Concatenate the asset path with the filename
      "/#{asset_path}/#{filename}"
    end
  end

  Liquid::Template.register_tag('post_asset_dir', PostAssetDirTag)
  Liquid::Template.register_filter(PostAssetPathFilter)
end
