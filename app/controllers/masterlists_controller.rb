class MasterlistsController < ApplicationController
  before_action :set_masterlist, only: [:edit, :update, :destroy]

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

  def destroy
    @masterlist.destroy
    redirect_to masterlists_path, notice: 'Envelope Deleted Successfully!'
  end

  def select_multiple

    if params[:commit] == "Delete selected"
      if params[:masterlist_ids].blank?
        redirect_to masterlists_path, notice: 'No envelopes selected'
      else
        @masterlist_hash =  params[:masterlist_ids]
        @array_try = []
        @masterlist_hash.each { |k,v| @array_try.push(k)}
        Masterlist.where(id: @array_try).destroy_all
        respond_to do |format|
          format.html { redirect_to masterlists_path, notice: 'Envelope Deleted Successfully!' }
          format.json { head :no_content }
        end
      end

    elsif params[:commit] == "Create selected"
      puts 'Sending out these envelopes tentatively'
      if params[:masterlist_ids].blank?
        redirect_to masterlists_path, notice: 'No envelopes selected'
      else
        @masterlist_hash =  params[:masterlist_ids]
        @array_try = []
        @masterlist_hash.each { |k,v| @array_try.push(k)}
        puts @array_try
        @masterlists = current_user.masterlists.where(id: @array_try)
        Masterlist.send_env(@masterlists)
        Masterlist.where(id: @array_try).destroy_all
        respond_to do |format|
          format.html { redirect_to masterlists_path, notice: 'Envelope Sent Out Successfully!' }
          format.json { head :no_content }
        end
      end

    else params[:commit] == "Download selected"
      puts 'Downloading these envelopes tentatively'
      if params[:masterlist_ids].blank?
        redirect_to masterlists_path, notice: 'No envelopes selected'
      else
        @masterlist_hash =  params[:masterlist_ids]
        @array_try = []
        @masterlist_hash.each { |k,v| @array_try.push(k)}
        puts @array_try
        @masterlists = current_user.masterlists.where(id: @array_try)
        Masterlist.get_doc(@masterlists)
        respond_to do |format|
          format.html { redirect_to masterlists_path, notice: 'Envelope Downloaded Successfully!' }
          format.json { head :no_content }
        end
      end
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

