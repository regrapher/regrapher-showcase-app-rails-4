namespace :simulator do
  task import_tweets: :environment do
    client = Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV['CONSUMER_KEY']
      config.consumer_secret = ENV['CONSUMER_SECRET']
    end

    ENV['IMPORTED_ACCOUNTS'].split(';').each do |entry|
      twitter_user, user_email, user_password = entry.split(',', 3)
      timeline                                = client.user_timeline(twitter_user)
      latest_posts_hashes                     = Post.joins(:user).where(users: { email: user_email }).
          order(id: :desc).limit(timeline.length).
          pluck(:body).map(&:hash).to_set
      Mechanize.start do |agent|
        page = agent.get("#{ENV['DOMAIN_NAME']}/users/sign_in")
        page.forms.first.tap do |form|
          form['user[email]']    = user_email
          form['user[password]'] = user_password
          page = form.submit
        end

        authenticity_token = page.at('meta[name="csrf-token"]').attr('content')

        page.css('.post.liked .post-actions-dislike a').to_a.sample(4).each do |e|
          agent.delete("#{ENV['DOMAIN_NAME']}#{e.attr('href')}", authenticity_token: authenticity_token)
        end

        page.css('.post:not(.liked) .post-actions-like a').to_a.sample(4).each do |e|
          agent.post("#{ENV['DOMAIN_NAME']}#{e.attr('href')}", authenticity_token: authenticity_token)
        end

        page.css('.post.self .post-actions-delete a').to_a.last(rand(1)).each do |e|
          agent.delete("#{ENV['DOMAIN_NAME']}#{e.attr('href')}", authenticity_token: authenticity_token)
        end

        timeline.reject { |t| latest_posts_hashes.include?(t.text.hash) }.each do |tweet|
          page = agent.get("#{ENV['DOMAIN_NAME']}/posts/new")
          page.forms.first.tap do |form|
            form['post[body]'] = tweet.text
            page = form.submit
          end
        end

        authenticity_token = page.at('meta[name="csrf-token"]').attr('content')
        agent.delete("#{ENV['DOMAIN_NAME']}/users/sign_out", authenticity_token: authenticity_token)
      end
    end
  end
end
