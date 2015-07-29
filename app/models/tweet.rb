class Tweet < ActiveRecord::Base
  IDLE = 'idle'

  validates_presence_of :text, :action

  def self.reached
    Tweet.all.pluck('id').map{ |tweet_id|
      Donor.broadcasters_of(tweet_id).count
    }.sum()
  end
  
  def status
    read_attribute(:status) || IDLE
  end

  def broadcast options
    BroadcastTweetJob.perform_later self, options if status == IDLE
  end
end
