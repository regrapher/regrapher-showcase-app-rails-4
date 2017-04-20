namespace :simulator do
  task import_tweets: :environment do
    client = Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV['CONSUMER_KEY']
      config.consumer_secret = ENV['CONSUMER_SECRET']
    end

    ENV['IMPORTED_ACCOUNTS'].split(';').each do |entry|
      twitter_user, user_email, user_password = entry.split(',', 3)
      timeline                                = client.user_timeline(twitter_user)
      latest_posts                            = Post.joins(:user).where(users: { email: user_email }).
          order(id: :desc).limit(timeline.length).
          pluck(:body).map(&:hash).to_set
      Mechanize.start do |agent|
        page = agent.get("#{ENV['DOMAIN_NAME']}/users/sign_in")
        page.forms.first.tap do |form|
          form['user[email]']    = user_email
          form['user[password]'] = user_password
          form.submit
        end
        timeline.reject { |t| latest_posts.include?(t.text.hash) }.each do |tweet|
          page = agent.get("#{ENV['DOMAIN_NAME']}/posts/new")
          page.forms.first.tap do |form|
            form['post[body]'] = tweet.text
            form.submit
          end
        end
      end
    end
  end
end
