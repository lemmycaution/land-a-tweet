require 'tempfile'
class BroadcastTweetJob < ActiveJob::Base
  queue_as :default

  def perform(tweet, options = {})
    options ||= {}
    donors = Donor.not_broadcasters_of(tweet.id)
    donors = donors.has_donation_equal_or_greater_than(options[:donations_greater_than].to_i || 1)
    if options[:donor_ids]
      options[:donor_ids] = options[:donor_ids].compact.uniq
      donors = donors.where(id: options[:donor_ids]) unless options[:donor_ids].empty?
    end
    donors = donors.limit(options[:limit].to_i) if options[:limit]
    donors = donors.order(:created_at)
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
          rescue Exception => e
            result = e.message
          end
        end

        donor.payload['broadcasts'][tweet.id] = {result: result, tweet_id: tweet_id}
        donor.save!
      rescue Exception => e
        Rails.logger.error e.message
        client.destroy_tweet tweet_id if tweet_id
      end
    end
  end
end
