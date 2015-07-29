class Donor < ActiveRecord::Base
  validates :donations, numericality: { only_integer: true, greater_than: 0 }, on: :update
  
  def self.find_or_create_by_oauth auth_hash
    self.find_for_oauth(auth_hash) || self.create!(payload: auth_hash.merge({broadcasts: {}, donations: 0}))
  end
  def self.find_for_oauth auth
    self.find_by("payload->>'provider' = ? AND payload->>'uid' = ?", auth[:provider], auth[:uid])
  end
  def self.has_donation_equal_or_greater_than num
    self.where("(payload->>'donations')::int >= ?", num)
  end
  def self.broadcasters
    self.where("(payload->'broadcasts'->>?) != ?", '{}')
  end
  def self.broadcasters_of tweet_id
    self.where("payload->'broadcasts'->?->>'result' = ?", tweet_id, 'OK')
  end
  def self.not_broadcasters_of tweet_id
    self.where("(payload->'broadcasts'->?) IS NULL OR payload->'broadcasts'->?->>'result' != ?", tweet_id, tweet_id, 'OK')
  end
  def self.available_donations_count
    self.has_donation_equal_or_greater_than(1).pluck("(payload->>'donations')::int").sum()
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
  def token
    payload.try(:[],'credentials').try(:[], 'token')
  end
  def secret
    payload.try(:[],'credentials').try(:[], 'secret')
  end
end
