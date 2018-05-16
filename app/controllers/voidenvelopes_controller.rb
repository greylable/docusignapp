class VoidenvelopesController < ApplicationController
  require 'csv'
  before_action :set_voidenvelope, only: [:destroy, :edit, :update, :show]

  def index
    @voidenvelopes = current_user.voidenvelopes
    @completed_voidenvelopes = current_user.voidenvelopes.where(status: 'voided')
    @incomplete_voidenvelopes = current_user.voidenvelopes.where.not(status: 'voided')
  end

  def import
    Voidenvelope.import(params[:file], current_user)
    redirect_to voidenvelopes_path, notice: "Activity Data Imported!"
  end

  def new
    @voidenvelope = current_user.voidenvelopes.new
  end

  def create
    @voidenvelope = current_user.voidenvelopes.new(voidenvelopes_params)
    if @voidenvelope.save!
      redirect_to voidenvelopes_path, notice: 'Void Request Created Successfully!'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @voidenvelope.update(voidenvelopes_params)
      redirect_to voidenvelopes_path, notice: 'Void Request Updated Successfully!'
    else
      render :edit
    end
  end

  def destroy
    @voidenvelope.destroy
    redirect_to voidenvelopes_path, notice: 'Void Request Deleted Successfully!'
  end

  def show
  end

  def destroy_multiple
    if params[:voidenvelope_ids].blank?
      redirect_to voidenvelopes_path, notice: "No contacts selected"
    else
      @voidenvelope_hash =  params[:voidenvelope_ids]
      @array_try = []
      @voidenvelope_hash.each { |k,v| @array_try.push(k)}
      Voidenvelope.where(id: @array_try).destroy_all
      respond_to do |format|
        format.html { redirect_to voidenvelopes_path, notice: 'Void Request Deleted Successfully!' }
        format.json { head :no_content }
      end
    end
  end

  private

  def set_voidenvelope
    @voidenvelope = Voidenvelope.find(params[:id])
  end

  def voidenvelopes_params
    params.require(:voidenvelope).permit(:name, :void_reason, :envelope_id)
  end
end