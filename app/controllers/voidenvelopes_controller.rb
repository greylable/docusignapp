class VoidenvelopesController < ApplicationController
  # before_action :set_void_env, only: [:destroy, :edit, :update, :show]
  def index
    @voidenvelope = current_user.voidenvelopes
  end

  # def import
  #   @void_env.import(params[:file])
  #   redirect_to root_url, notice: "Activity Data Imported!"
  # end

  # def create
  #   @void_env = current_user.void_envs.new(void_env_params)
  #   if @void_env.save!
  #     redirect_to void_env_params, notice: 'Void Batch Created Successfully!'
  #   else
  #     render :new
  #   end
  # end

  def new
    @voidenvelope = current_user.voidenvelopes.new
  end

  def create
    @voidenvelope = current_user.voidenvelopes.new(voidenvelopes_params)
    if @voidenvelope.save!
      redirect_to voidenvelopes_params, notice: 'Void Request Created Successfully!'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @goal.update(voidenvelopes_params)
      redirect_to voidenvelopes_path, notice: 'Void Request Updated Successfully!'
    else
      render :edit
    end
  end

  def destroy
    @goal.destroy
    redirect_to voidenvelopes_path, notice: 'Void Request Deleted Successfully!'
  end

  def show
  end


  private

  # def set_void_env
  #   @void_envs = Void_env.find(params[:id])
  # end

  def voidenvelopes_params
    params.require(:voidenvelope).permit(:name, :void_reason, :envelope_id)
  end
end