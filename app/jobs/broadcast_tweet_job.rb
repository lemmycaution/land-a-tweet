require 'tempfile'
class BroadcastTweetJob < ActiveJob::Base
  queue_as :default

  def perform(tweet, options = {})
    tweet.update(status: Tweet::SENDING)
    options ||= {}
    donors = Donor.for_broadcasting(tweet, options)
    reached = 0
    return tweet.update(status: Tweet::IDLE) if donors.empty?
    donors.find_each do |donor|
      tweet_id = nil
      begin
        unless donor.token && donor.secret
          result = 'credentials missing'
        else      
          begin
            client = Twitter::REST::Client.new do |config|
              config.consumer_key        = ENV['API_KEY']
              config.consumer_secret     = ENV['API_SECRET']
              config.access_token        = donor.token
              config.access_token_secret = donor.secret
            end

            tweet_id = tweet.image.present? ? 
              client.update_with_media(tweet.text, tweet.image.download).try(:id) :
              client.update(tweet.text).try(:id)

            result = 'OK'
            donor.donations -= 1
            reached += 1
          rescue Exception => e
            # TODO: make it DRY
            if tweet_id
              client.destroy_tweet tweet_id 
              donor.donations += 1
              reached -= 1
            end
            result = e.message
          end
        end

        donor.payload['broadcasts'][tweet.id] = {result: result, tweet_id: tweet_id}
        donor.save!
      rescue Exception => e
        Rails.logger.error e.message
        puts e.message
        # TODO: make it DRY
        if tweet_id
          client.destroy_tweet tweet_id 
          donor.donations += 1
          reached -= 1
        end
      end
    end
    status = Donor.broadcasters_of(tweet.id).count == reached ? Tweet::SENT : Tweet::PARTLY_SENT
    tweet.update(status: "#{status} [#{reached.to_s}]")
  end

end
