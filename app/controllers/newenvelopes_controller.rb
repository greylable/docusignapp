class NewenvelopesController < ApplicationController
  # before_action before_action :set_goal, only: [:destroy, :edit, :update, :show]

  def index
    @newenvelopes = current_user.newenvelopes
  end

  def new
    @newenvelope = current_user.newenvelopes.new
  end

  def create
    @newenvelope = current_user.newenvelopes.new(newenvelopes_params)
    if @newenvelope.save!
      redirect_to newenvelopes_path, notice: 'New Envelope Request Created Successfully!'
    else
      render :new
    end
  end

  private

  def set_newenvelope
    @newenvelope = Newenvelope.find(params[:id])
  end

  def newenvelopes_params
    params.require(:newenvelope).permit(:name, :rental, :nric, :email)
  end

end