class ResendenvsController < ApplicationController
  before_action :set_resendenv, only: [:destroy, :edit, :update, :show]

  def index
    @resendenvs = current_user.resendenvs
  end

  def import
    Resendenv.import(params[:file], current_user)
    redirect_to resendenvs_path, notice: 'Activity Data Imported!'
  end

  def new
    @resendenv = current_user.resendenvs.new
  end

  def create
    @resendenv = current_user.resendenvs.new(resendenvs_params)
    if @resendenv.save!
      redirect_to resendenvs_path, notice: 'New Envelope Request Created Successfully!'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @resendenv.update(resendenvs_params)
      redirect_to resendenvs_path, notice: 'New Envelope Request Updated Successfully!'
    else
      render :edit
    end
  end

  def destroy
    @resendenv.destroy
    redirect_to resendenvs_path, notice: 'New Envelope Request Deleted Successfully!'
  end

  def select_multiple
    if params[:commit] == "Delete selected"
      if params[:resendenv_ids].blank?
        redirect_to resendenvs_path, notice: 'No envelopes selected'
      else
        @resendenv_hash =  params[:resendenv_ids]
        @array_try = []
        @resendenv_hash.each { |k,v| @array_try.push(k)}
        Resendenv.where(id: @array_try).destroy_all
        respond_to do |format|
          format.html { redirect_to resendenvs_path, notice: 'New Envelope Request Deleted Successfully!' }
          format.json { head :no_content }
        end
      end
    else params[:commit] == "Create selected"
    puts 'Sending out these envelopes tentatively'
    if params[:resendenv_ids].blank?
      redirect_to resendenvs_path, notice: 'No envelopes selected'
    else
      @resendenv_hash =  params[:resendenv_ids]
      @array_try = []
      @resendenv_hash.each { |k,v| @array_try.push(k)}
      puts @array_try
      @resendenvs = current_user.resendenvs.where(id: @array_try)
      Resendenv.send_env(@resendenvs)
      Resendenv.where(id: @array_try).destroy_all
      respond_to do |format|
        format.html { redirect_to resendenvs_path, notice: 'New Envelope Request Sent Out Successfully!' }
        format.json { head :no_content }
      end
    end
    end
  end

  private

  def set_resendenv
    @resendenv = Resendenv.find(params[:id])
  end

  def resendenvs_params
    params.require(:resendenv).permit(:envelope_id, :email, :rental, :name, :nric, :mailing_address, :driver_phone_no, :birthday, :pickup_date,
                                      :vehicle_make, :vehicle_model, :vehicle_colour, :licence_plate,  :master_rate, :weekly_rate,
                                      :min_rental_period, :deposit, :acccessnote, :note)
  end

end

