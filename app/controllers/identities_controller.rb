class IdentitiesController < ApiController
  before_filter :authenticate_current_user

  def update
    # identity = Identity.find_by!(id: params[:id])
    # identity.payload['donations'] = params[:identity][:donations]
    # identity.save!
    identity = Identity.find_by!(id: params[:id])
    identity.update!(donations: params[:identity][:donations])
    render json: identity.reload.donations
  end

end
