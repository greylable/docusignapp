class ResendenvsController < ApplicationController
  before_action :set_resendenv, only: [:destroy, :edit, :update]

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
      redirect_to resendenvs_path, notice: 'Resend Envelope Request Created Successfully!'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @resendenv.update(resendenvs_params)
      redirect_to resendenvs_path, notice: 'Resend Envelope Request Updated Successfully!'
    else
      render :edit
    end
  end

  def destroy
    @resendenv.destroy
    redirect_to resendenvs_path, notice: 'Resend Envelope Request Deleted Successfully!'
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
          format.html { redirect_to resendenvs_path, notice: 'Resend Envelope Request Deleted Successfully!' }
          format.json { head :no_content }
        end
      end

    elsif params[:commit] == "Resend selected"
      puts 'Sending out these envelopes tentatively'
      if params[:resendenv_ids].blank?
        redirect_to resendenvs_path, notice: 'No envelopes selected'
      else
        @resendenv_hash =  params[:resendenv_ids]
        @array_try = []
        @resendenv_hash.each { |k,v| @array_try.push(k)}
        @resendenvs = current_user.resendenvs.where(id: @array_try)
        Resendenv.resend_env(@resendenvs)
        Resendenv.where(id: @array_try).destroy_all
        respond_to do |format|
          format.html { redirect_to resendenvs_path, notice: 'Envelope Resent Successfully!' }
          format.json { head :no_content }
        end
      end

    elsif params[:commit] == "Email blurb"
      if params[:resendenv_ids].blank?
        redirect_to resendenvs_path, notice: 'No envelopes selected'
      else
        @resendenv_hash =  params[:resendenv_ids]
        @array_try = []
        @resendenv_hash.each { |k,v| @array_try.push(k)}
        @resendenvs = current_user.resendenvs.where(id: @array_try)
        Resendenv.import_msg(@resendenvs, params[:file], current_user)
        respond_to do |format|
          format.html { redirect_to resendenvs_path, notice: 'Email Blurb Uploaded!' }
          format.json { head :no_content }
        end
      end

    else params[:commit] == "Fetch selected"
      puts 'Fetching these envelopes tentatively'
      if params[:resendenv_ids].blank?
        redirect_to resendenvs_path, notice: 'No envelopes selected'
      else
        @resendenv_hash =  params[:resendenv_ids]
        @array_try = []
        @resendenv_hash.each { |k,v| @array_try.push(k)}
        @resendenvs = current_user.resendenvs.where(id: @array_try)
        Resendenv.fetch_info(@resendenvs, current_user)
        respond_to do |format|
          format.html { redirect_to resendenvs_path, notice: 'Envelope Information Fetched Successfully!' }
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
                                      :vehicle_make, :vehicle_model, :vehicle_colour, :licence_plate, :master_rate, :weekly_rate,
                                      :min_rental_period, :deposit, :accesscode, :note, :email_blurb)
  end

end

