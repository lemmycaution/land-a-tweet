class Tweet < ActiveRecord::Base
  IDLE = 'idle'
  SENDING = 'sending'
  PARTLY_SENT = 'partly_sent'
  SENT = 'sent'

  validates_presence_of :text, :action
  attachment :image

  def self.reached
    Tweet.all.pluck('id').map{ |tweet_id|
      Donor.broadcasters_of(tweet_id).count
    }.sum()
  end
  
  def status
    read_attribute(:status) || IDLE
  end
  
  [IDLE, SENDING, PARTLY_SENT, SENT].each do |status_name|
    define_method "#{status_name}?" do
      status == status_name
    end
    
  end

  def broadcast options
    BroadcastTweetJob.perform_later self, options if status != SENT
  end
end
