feed.entry item, id: "urn:uuid:#{item.guid}", published: item.published_at, url: item.permalink_url do |entry|
  entry.author do
    name = begin
             item.user.name
           rescue
             item.author
           end
    email = begin
              item.user.email
            rescue
              nil
            end
    entry.name name
    entry.email email unless email.blank? || !this_blog.link_to_author
  end

  if item.is_a?(Note)
    entry.title truncate(item.html(:body).strip_html, length: 80, separator: ' ', omissions: '...'), 'type' => 'html'
  else
    entry.title item.title, 'type' => 'html'
  end

  if item.is_a?(Article)

    item.tags.each do |tag|
      entry.category 'term' => tag.display_name, 'scheme' => tag_url(tag.permalink)
    end

    item.resources.each do |resource|
      if resource.size > 0 # The Atom spec disallows files with size=0
        entry.tag! :link, 'rel' => 'enclosure',
                          type: resource.mime,
                          title: item.title,
                          href: this_blog.file_url(resource.upload_url),
                          length: resource.size
      else
        entry.tag! :link, 'rel' => 'enclosure',
                          type: resource.mime,
                          title: item.title,
                          href: this_blog.file_url(resource.upload_url)
      end
    end
  end
  content_html = fetch_html_content_for_feeds(item, this_blog)
  entry.content content_html + item.get_rss_description, 'type' => 'html'
end
