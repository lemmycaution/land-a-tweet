require 'tempfile'
class BroadcastTweetJob < ActiveJob::Base
  queue_as :default

  def perform(tweet, options = {})
    tweet.update(status: Tweet::SENDING)
    options ||= {}
    donors = Donor.by_action(tweet.action).not_broadcasters_of(tweet.id)
    puts "D0 #{donors.count}"
    Rails.logger.debug "D0 #{donors.count}"
    donors = donors.has_donation_equal_or_greater_than([options[:donations_greater_than].to_i, 1].max)
    puts "D1 #{donors.count}"
    Rails.logger.debug "D1 #{donors.count}"
    if options[:donor_ids] && (options[:donor_ids] = options[:donor_ids].reject{|e| e.blank? }.compact.uniq).any?
      donors = donors.where(id: options[:donor_ids])
      puts "D2 #{donors.count} ids: #{options[:donor_ids]}"
      Rails.logger.debug "D2 #{donors.count} ids:options[:donor_ids]"
    end
    donors = donors.limit(options[:limit].to_i) if options[:limit]
    puts "D3 #{donors.count}"
    Rails.logger.debug "D3 #{donors.count}"
    donors = donors.order(:created_at)
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
            result = e.message
          end
        end

        donor.payload['broadcasts'][tweet.id] = {result: result, tweet_id: tweet_id}
        donor.save!
      rescue Exception => e
        Rails.logger.error e.message
        puts e.message
        client.destroy_tweet tweet_id if tweet_id
      end
    end
    tweet.update(status: Donor.broadcasters_of(tweet.id).count == reached ? Tweet::SENT : Tweet::PARTLY_SENT)
  end
end
