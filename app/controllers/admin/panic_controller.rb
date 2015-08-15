class Admin::PanicController < Admin::BaseController
  def index
  end

  def stop_dj
    Rails.logger.error "panic:stop_dj"
    redirect_to admin_root_path
  end

  def start_dj
    Rails.logger.error "panic:start_dj"
    redirect_to admin_root_path
  end

  def delete_all_donors
    Donor.delete_all
    redirect_to admin_root_path
  end

  def suspend_frontend
    `mv #{Rails.application.root}/public/index.html.suspend #{Rails.application.root}/public/index.html`
    redirect_to admin_root_path
  end

  def activate_frontend
    `mv #{Rails.application.root}/public/index.html #{Rails.application.root}/public/index.html.suspend`
    redirect_to admin_root_path
  end
end