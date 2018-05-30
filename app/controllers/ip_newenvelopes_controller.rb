class IpNewenvelopesController < ApplicationController
  before_action :set_ip_newenvelope, only: [:destroy, :edit, :update, :show]

  def index
    @ip_newenvelopes = current_user.ip_newenvelopes
  end

  def import
    IpNewenvelope.import(params[:file], current_user)
    redirect_to ip_newenvelopes_path, notice: 'Activity Data Imported!'
  end

  def new
    @ip_newenvelope = current_user.ip_newenvelopes.new
  end

  def create
    @ip_newenvelope = current_user.ip_newenvelopes.new(ip_newenvelopes_params)
    if @ip_newenvelope.save!
      redirect_to ip_newenvelopes_path, notice: 'New Envelope Request Created Successfully!'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @ip_newenvelope.update(ip_newenvelopes_params)
      redirect_to ip_newenvelopes_path, notice: 'New Envelope Request Updated Successfully!'
    else
      render :edit
    end
  end

  def destroy
    @ip_newenvelope.destroy
    redirect_to ip_newenvelopes_path, notice: 'New Envelope Request Deleted Successfully!'
  end

  def select_multiple
    if params[:commit] == "Delete selected"
      if params[:ip_newenvelope_ids].blank?
        redirect_to ip_newenvelopes_path, notice: 'No envelopes selected'
      else
        @ip_newenvelope_hash =  params[:ip_newenvelope_ids]
        @array_try = []
        @ip_newenvelope_hash.each { |k,v| @array_try.push(k)}
        IpNewenvelope.where(id: @array_try).destroy_all
        respond_to do |format|
          format.html { redirect_to ip_newenvelopes_path, notice: 'New Envelope Request Deleted Successfully!' }
          format.json { head :no_content }
        end
      end
    else params[:commit] == "Create selected"
      puts 'Sending out these envelopes tentatively'
      if params[:ip_newenvelope_ids].blank?
        redirect_to ip_newenvelopes_path, notice: 'No envelopes selected'
      else
        @ip_newenvelope_hash =  params[:ip_newenvelope_ids]
        @array_try = []
        @ip_newenvelope_hash.each { |k,v| @array_try.push(k)}
        puts @array_try
        @ip_newenvelopes = current_user.ip_newenvelopes.where(id: @array_try)
        IpNewenvelope.send_env(@ip_newenvelopes)
        IpNewenvelope.where(id: @array_try).destroy_all
        respond_to do |format|
          format.html { redirect_to ip_newenvelopes_path, notice: 'New Envelope Request Sent Out Successfully!' }
          format.json { head :no_content }
        end
      end
    end
  end
  
  private

  def set_ip_newenvelope
    @ip_newenvelope = IpNewenvelope.find(params[:id])
  end

  def ip_newenvelopes_params
    params.require(:ip_newenvelope).permit(:ip_email, :nric, :ip_name, :driver_phone_no, :licence_plate, :min_rental_period,
                                           :name_of_bank, :bank_account_no, :emergency_name, :emergency_phone_no,
                                           :vehicle_make, :vehicle_model, :pickup_date, )
  end

end

