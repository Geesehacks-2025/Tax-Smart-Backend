class UserProfilesController < ApplicationController
    # POST /user_profiles
  def create
    # Create a new user profile from the parameters passed in the request
    user_profile = UserProfile.find_or_initialize_by(email: user_profile_params[:email])

    # Update the attributes of the record
    if user_profile.update(user_profile_params)
      render json: { message: "User profile successfully created/updated.", user_profile: user_profile }, status: :ok
    else
      render json: { errors: user_profile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # Only allow trusted parameters through
  def user_profile_params
    params.require(:user_profile).permit(:name, :email, :phone_number, :address, :province, :country, :profession, :marital_status)
  end
end
