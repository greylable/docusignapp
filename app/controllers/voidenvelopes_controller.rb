class VoidenvelopesController < ApplicationController
  require 'csv'
  before_action :authenticate_user!
  before_action :set_voidenvelope, only: [:destroy, :edit, :update, :show]

  def index
    @voidenvelopes = current_user.voidenvelopes
    @completed_voidenvelopes = current_user.voidenvelopes.where(status: 'voided')
    @incomplete_voidenvelopes = current_user.voidenvelopes.where.not(status: 'voided')
  end

  def import
    if params[:file].present?
      Voidenvelope.import(params[:file], current_user)
      redirect_to voidenvelopes_path, notice: 'Activity Data Imported!'
    else
      redirect_to new_voidenvelope_path, notice: 'Please Upload a File'
    end
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

  def select_multiple
    if params[:commit] == "Delete selected"
      if params[:voidenvelope_ids].blank?
        redirect_to voidenvelopes_path, notice: 'No envelopes selected'
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
    else params[:commit] == "Void selected"
      puts 'Voiding these envelopes tentatively'
      if params[:voidenvelope_ids].blank?
        redirect_to voidenvelopes_path, notice: 'No envelopes selected'
      else
        @voidenvelope_hash =  params[:voidenvelope_ids]
        @array_try = []
        @voidenvelope_hash.each { |k,v| @array_try.push(k)}
        @voidenvelopes = current_user.voidenvelopes.where(id: @array_try)
        @void_array = Voidenvelope.void(@voidenvelopes)
        Voidenvelope.where(id: @void_array).destroy_all
        respond_to do |format|
          format.html { redirect_to voidenvelopes_path, notice: 'Void Request Voided Successfully!' }
          format.json { head :no_content }
        end
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