class DonationsController < ApiController
  before_filter :authenticate_current_user

  # TODO: optimize this?
  def update
    donor = Donor.find_by!(id: params[:id])
    donor.update!(donations: params[:donor][:donations])
    donor.update!(action: params[:donor][:action]) if params[:donor][:action]
    render json: params[:donor][:donations]
  end
  

end