class MasterlistsController < ApplicationController
  before_action :set_masterlist, only: [:edit, :update, :show]

  def index
    @masterlists = current_user.masterlists
  end

  def new
    @masterlist = current_user.masterlists.new
  end

  def create
    @masterlist = current_user.masterlists.new(newenvelopes_params)
    if @masterlist.save!
      redirect_to masterlists_path, notice: 'Request Created Successfully!'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @masterlist.update(masterlists_params)
      redirect_to masterlists_path, notice: 'Masterlist Updated Successfully!'
    else
      render :edit
    end
  end

  private

  def set_masterlist
    @masterlist = Masterlist.find(params[:id])
  end

  def masterlists_params
    params.require(:masterlist).permit(:envelope_id, :created_time, :recipient_email, :status, :recipient_type,
                                       :completed_time, :declined_time, :declined_reason, :subject_title, :auth_status,
                                       :auth_timestamp, :delivered_date_time, :note, :accesscode, :recipient_status,
                                       :rental)
  end

end

