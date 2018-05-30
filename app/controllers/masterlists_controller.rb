class MasterlistsController < ApplicationController
  before_action :set_masterlist, only: [:edit, :update]

  def index
    @masterlists = current_user.masterlists.page params[:page]
  end

  def search
  end

  def search_go
    if params[:envelope_id]!=""
      @masterlist_search = Masterlist.where('envelope_id LIKE ?', "%#{params[:envelope_id]}%")
      puts @masterlist_search
      puts params[:envelope_id]
      redirect_to search_view_masterlists_path
    end
  end

  def search_view
    @masterlist_search
  end

  def new
    @masterlist = current_user.masterlists.new
  end

  def create
    @masterlist = current_user.masterlists.new(masterlists_params)
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

  def select_multiple
    if params[:commit] == "Refresh masterlist"
      Masterlist.destroy_all
      Masterlist.refresh_masterlist
      redirect_to masterlists_path, notice: 'New Envelope Request Deleted Successfully!'
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

