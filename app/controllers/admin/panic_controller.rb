class Admin::PanicController < Admin::BaseController
  def index
  end

  def stop_dj
    `bundle exec bin/delayed_job stop`
    render nothing: true, status: $?.exitstatus === 0 ? 200 : 500
  end

  def start_dj
    `bundle exec bin/delayed_job stop`
    render nothing: true, status: $?.exitstatus === 0 ? 200 : 500
  end

  def delete_all_donors
    Donor.delete_all
    redirect_to admin_root
  end

  def suspend_frontend
    `mv #{Rails.app.root}/public/index.html.suspend #{Rails.app.root}/public/index.html`
    
  end

  def activate_frontend
    `mv #{Rails.app.root}/public/index.html #{Rails.app.root}/public/index.html.suspend`
  end
end