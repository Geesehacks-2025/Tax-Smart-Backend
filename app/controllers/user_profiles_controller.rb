class UserProfilesController < ApplicationController
    # POST /user_profiles
  def create
    # Create a new user profile from the parameters passed in the request
    @user_profile = UserProfile.new(user_profile_params)

    if @user_profile.save
      # If saved successfully, respond with the created user profile as JSON
      render json: @user_profile, status: :created
    else
      # If not saved, respond with errors
      render json: @user_profile.errors, status: :unprocessable_entity
    end
  end

  private

  # Only allow trusted parameters through
  def user_profile_params
    params.require(:user_profile).permit(:name, :email, :phone_number, :address, :province, :country, :profession, :marital_status)
  end
end
