class UsersController < ApplicationController
  load_and_authorize_resource

  def index
    @users = User.order('admin_user DESC, id')
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      if @user.admin_user != true
        @user.admin_user == false
      end
      flash[:notice] = "Successfully created User!"
      redirect_to users_path
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_update_params)
      flash[:notice] = "Successfully updated User!"
      redirect_to users_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      flash[:notice] = "Successfully deleted User!"
      redirect_to users_path
    end
  end
  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_update_params
    params.require(:user).permit(:admin_user)
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :admin_user)
  end
end