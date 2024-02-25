module Jekyll
  class ModifyPostImagePaths < Generator
    priority :high

    def generate(site)
      site.posts.docs.each do |post|
        if post.data['image']
          # don't modify absolute URLs
          if post.data['image'].start_with?('http')
            next
          end

          asset_dir = if post['draft']
            "assets/attachments/drafts/#{post['slug']}"
          else
            "assets/attachments/#{post['date'].strftime('%Y/%m/%d')}/#{post['slug']}"
          end

          post.data['image'] = "/#{asset_dir}/#{post.data['image']}"
        else
          post.data['image'] = "/assets/img/card-image-placeholder.png"
        end
      end
    end
  end
end
