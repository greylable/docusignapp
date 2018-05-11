class NewenvelopesController < ApplicationController
  # before_action before_action :set_goal, only: [:destroy, :edit, :update, :show]
  def index
    # @envelopes = current_user.envelopes
  end

  def new
    # @envelope = current_user.envelopes.new
  end

  def create
    @envelope = current_user.envelopes.new(envelope_params)
    if @envelope.save!
      redirect_to envelope_params, notice: 'Journal Created Successfully!'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @envelope.update(envelope_params)
      redirect_to envelopes_path, notice: 'Journal Updated Successfully!'
    else
      render :edit
    end
  end

  def destroy
    @envelope.destroy
    redirect_to envelopes_path, notice: 'Journal Deleted Successfully!'
  end

  def show
  end

  private

  def set_envelope
    @envelope = envelope.find(params[:id])
  end

  def envelope_params
    params.require(:envelope).permit(:title, :deadline)
  end
end