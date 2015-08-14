module ApplicationHelper
  def hide_class is_button = false
    return unless current_user
    is_button && current_user.donations == 0 || !is_button && current_user.donations > 0 ? "hide" : nil
  end
  def tweet_donors
    @donors.by_action(@tweet.action).has_donation_equal_or_greater_than(1)
  end
  def max_tweet_donor_count
    tweet_donors.count
  end
  def action_param
    sanitize params[:actionname].try(:gsub, /javascript\:|\(|\)|\;|\'/, '')
  end
  def jobs_running
    `bin/delayed_job status`.include? 'running'
  end
end
