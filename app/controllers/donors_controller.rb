class DonorsController < ApiController
  before_filter :authenticate_current_user

  def update
    # donor = Donor.find_by!(id: params[:id])
    # donor.payload['donations'] = params[:donor][:donations]
    # donor.save!
    donor = Donor.find_by!(id: params[:id])
    donor.update!(donations: params[:donor][:donations])
    render json: donor.reload.donations
  end

end
