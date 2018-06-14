class NewenvelopesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_newenvelope, only: [:destroy, :edit, :update]

  def index
    @newenvelopes = current_user.newenvelopes
  end

  def import
    Newenvelope.import(params[:file], current_user)
    redirect_to newenvelopes_path, notice: 'Activity Data Imported!'
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

  def edit
  end

  def update
    if @newenvelope.update(newenvelopes_params)
      redirect_to newenvelopes_path, notice: 'New Envelope Request Updated Successfully!'
    else
      render :edit
    end
  end

  def destroy
    @newenvelope.destroy
    redirect_to newenvelopes_path, notice: 'New Envelope Request Deleted Successfully!'
  end

  def select_multiple
    if params[:commit] == "Delete selected"
      if params[:newenvelope_ids].blank?
        redirect_to newenvelopes_path, notice: 'No envelopes selected'
      else
        @newenvelope_hash =  params[:newenvelope_ids]
        @array_try = []
        @newenvelope_hash.each { |k,v| @array_try.push(k)}
        Newenvelope.where(id: @array_try).destroy_all
        respond_to do |format|
          format.html { redirect_to newenvelopes_path, notice: 'New Envelope Request Deleted Successfully!' }
          format.json { head :no_content }
        end
      end

    elsif params[:commit] == "Create selected"
      if params[:file].present?
        puts 'Sending out these envelopes tentatively'
        if params[:newenvelope_ids].blank?
          redirect_to newenvelopes_path, notice: 'No envelopes selected'
        else
          @newenvelope_hash =  params[:newenvelope_ids]
          @array_try = []
          @newenvelope_hash.each { |k,v| @array_try.push(k)}
          puts @array_try
          @newenvelopes = current_user.newenvelopes.where(id: @array_try)
          Newenvelope.send_env(@newenvelopes,params[:file])
          Newenvelope.where(id: @array_try).destroy_all
          respond_to do |format|
            format.html { redirect_to newenvelopes_path, notice: 'New Envelope Request Sent Out Successfully!' }
            format.json { head :no_content }
          end
        end
      else
        redirect_to newenvelopes_path, notice: 'Please Upload a File'
      end
    end
  end

  private

  def set_newenvelope
    @newenvelope = Newenvelope.find(params[:id])
  end

  def newenvelopes_params
    params.require(:newenvelope).permit(:email, :rental, :name, :nric, :mailing_address, :driver_phone_no, :birthday, :pickup_date,
                                        :vehicle_make, :vehicle_model, :vehicle_colour, :licence_plate,  :master_rate, :weekly_rate,
                                        :min_rental_period, :deposit, :acccessnote, :note)
  end

end

