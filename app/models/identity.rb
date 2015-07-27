class Identity < ActiveRecord::Base
  validates :donations, numericality: { only_integer: true, greater_than: 0 }

  def self.find_or_create_by_oauth auth_hash
    self.find_for_oauth(auth_hash) || self.create!(payload: auth_hash)
  end
  def self.find_for_oauth auth
    self.find_by("payload->>'provider' = ? AND payload->>'uid' = ?", auth[:provider], auth[:uid])
  end
  def donations
    payload['donations'].to_i
  end
  def donations= val
    payload['donations'] = val.to_i
  end

end
