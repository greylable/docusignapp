class NewenvelopesController < ApplicationController
  before_action :set_newenvelope, only: [:destroy, :edit, :update, :show]

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

  def destroy_multiple
    if params[:newenvelope_ids].blank?
      redirect_to newenvelopes_path, notice: "No contacts selected"
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
  end

  private

  def set_newenvelope
    @newenvelope = Newenvelope.find(params[:id])
  end

  def newenvelopes_params
    params.require(:newenvelope).permit(:name, :rental, :nric, :email, :mailing_address, :driver_phone_no, :birthday, :pickup_date,
                                        :vehicle_make, :vehicle_model, :vehicle_colour, :licence_plate,  :master_rate, :weekly_rate,
                                        :min_rental_period, :deposit, :payee_name, :name_of_bank, :bank_address, :bank_account_no,
                                        :bank_code, :branch_code, :swift_code, :driver_licence_no, :expiration_date, :driver_licence_class,
                                        :emergency_name, :emergency_nric, :emergency_mailing_address, :emergency_email, :emergency_phone_no, :emergency_birthday)
  end

end

