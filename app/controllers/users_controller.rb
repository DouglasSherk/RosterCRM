class UsersController < ApplicationController
  before_action :set_user

  def edit
  end

  # PATCH/PUT /user
  # PATCH/PUT /user
  def update
    respond_to do |format|
      if @user.update(users_params)
        format.html { redirect_to edit_user_path, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def users_params
      params.require(:user).permit(:city_country)
    end

    def set_user
      @user = current_user
    end
end
