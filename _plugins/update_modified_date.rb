Jekyll::Hooks.register :posts, :post_init do |post|
  commit_num = `git rev-list --count HEAD "#{post.path}"`.to_i

  if commit_num > 1
    post.data['updated'] = `git log -1 --pretty="%ad" --date=iso "#{post.path}"`
  end
end
