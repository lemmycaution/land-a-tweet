class Donor < ActiveRecord::Base
  # validates :donations, numericality: { only_integer: true, greater_than: 0 }, on: :update
  attr_accessor :action
  before_save :set_action
  after_update :update_tweet_statuses, if: 'donations > 0 && actions.try(:any?)'
  
  def self.find_or_create_by_oauth auth_hash
    self.find_for_oauth(auth_hash) || self.create!(payload: auth_hash.merge({broadcasts: {}, donations: 0, actions: []}))
  end
  def self.find_for_oauth auth
    self.find_by("payload ->> 'provider' = ? AND payload ->> 'uid' = ?", auth[:provider], auth[:uid])
  end
  def self.has_donation_equal_or_greater_than num
    self.where("(payload ->> 'donations')::int >= ?", num)
  end
  def self.broadcasters
    self.where("(payload -> 'broadcasts' ->> ?) != ?", '{}')
  end
  def self.broadcasters_of tweet_id
    self.where("payload->'broadcasts' -> ? ->> 'result' = ?", tweet_id, 'OK')
  end
  def self.not_broadcasters_of tweet_id
    self.where("(payload -> 'broadcasts' -> ?) IS NULL OR (payload -> 'broadcasts' -> ? ->> 'result') != ?", tweet_id, tweet_id, 'OK')
  end
  def self.available_donations_count
    self.has_donation_equal_or_greater_than(1).pluck("(payload ->> 'donations')::int").sum()
  end
  def self.by_action action
    self.where(["payload->'actions' ? :action", action: action])
  end
  def self.for_broadcasting tweet, options
    return 0 unless tweet.present?
    donors = self.by_action(tweet.action).not_broadcasters_of(tweet.id)
    donors = donors.has_donation_equal_or_greater_than([options[:donations_greater_than].to_i, 1].max)
    if options[:donor_ids] && (options[:donor_ids] = options[:donor_ids].reject{|e| e.blank? }.compact.uniq).any?
      donors = donors.where(id: options[:donor_ids])
    end
    donors = donors.limit(options[:limit].to_i) if options[:limit]
    donors = donors.order(:created_at)
    donors
  end
  
  def name
    payload['info']['name']
  end
  def donations
    payload['donations'].to_i
  end
  def donations= val
    payload['donations'] = val.to_i
  end
  def actions
    payload['actions'].to_a.compact.reject{|a| a.blank?}.uniq
  end
  def used_donations_count
    payload['broadcasts'].map{ |k,v| v['tweet_id'] }.compact.size
  end
  def token
    payload.try(:[],'credentials').try(:[], 'token')
  end
  def secret
    payload.try(:[],'credentials').try(:[], 'secret')
  end

  private
  
  def set_action
    payload['actions'] << action if action && !actions.include?(action)
  end
  
  def update_tweet_statuses
    actions.sort! { |x,y| action ? (y == action ? 1 : -1) : y <=> x }.each_with_index do |current_action, index|
      Tweet.sent_for_action(current_action).update_all(status: Tweet::PARTLY_SENT) if index < donations
    end
  end
end
