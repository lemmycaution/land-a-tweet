class DonationsController < ApiController
  before_filter :authenticate_current_user

  def update
    donor = Donor.find_by!(id: params[:id])
    donor.update!(donations: params[:donor][:donations])
    render json: params[:donor][:donations]
  end
end