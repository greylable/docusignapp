class MasterlistsController < ApplicationController
  before_action :set_masterlist, only: [:edit, :update]
  before_action :set_masterlist_search, only: [:results]
  before_action :authenticate_user!, except: [:refresh]

  def index
    @masterlists = Masterlist.page params[:page]
  end

  def import
    Masterlist.import(params[:file], current_user)
    redirect_to masterlists_path, notice: 'Activity Data Imported!'
  end

  def export
    respond_to do |format|
      format.html
      format.csv {send_data Masterlist.to_csv}
      # redirect_to masterlists_path, notice: 'Activity Data Exported!'
    end
  end

  def search
  end

  def results
  end

  def refresh
    # head :ok
    Masterlist.refresh_masterlist
    # render :nothing => true
  end


  def new
    @masterlist = Masterlist.new
  end

  def create
    @masterlist = Masterlist.new(masterlists_params)
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
    if params[:commit] == "Download selected"
      if params[:masterlist_ids].blank?
        redirect_to masterlists_path, notice: 'No envelopes selected'
      else
        @masterlist_hash = params[:masterlist_ids]
        @array_try = []
        @masterlist_hash.each {|k, v| @array_try.push(k)}
        @masterlists = Masterlist.where(id: @array_try)

        download_zip(@masterlists)
      end
    end
  end

  def download_zip(masterlists)
    require 'rubygems'
    require 'zip'
    Masterlist.docu_auth
    compressed_filestream = Zip::OutputStream.write_buffer do |stream|
      masterlists.each do |masterlist|
        if masterlist.status == 'completed'
          related_data = Masterlist.get_doc(masterlist)
          filename = related_data[0]
          base64_data = related_data[1]
          temp_pdf = Tempfile.new(filename)
          temp_pdf.binmode
          temp_pdf.write base64_data
          temp_pdf.rewind
          stream.put_next_entry("#{filename}.pdf")
          stream.write IO.read("#{temp_pdf.path}")
          temp_pdf.close
        end
      end
    end
    compressed_filestream.rewind
    send_data compressed_filestream.read, filename: "contracts.zip"
  end

  private

  def set_masterlist
    @masterlist = Masterlist.find(params[:id])
  end

  def set_masterlist_search
    puts params
    if params[:envelope_id].present?
      puts 'in envelope'
      @masterlist_search = Masterlist.where('envelope_id LIKE ?', "%#{params[:envelope_id]}%")
    elsif params[:accesscode].present?
      puts 'in accesscode'
      @masterlist_search = Masterlist.where('accesscode LIKE ?', "%#{params[:accesscode]}%")
    elsif params[:rental].present?
      puts 'in rental'
      @masterlist_search = Masterlist.where('rental LIKE ?', "%#{params[:rental]}%")
    elsif params[:recipient_email].present?
      puts 'in recipient_email'
      @masterlist_search = Masterlist.where('recipient_email LIKE ?', "%#{params[:recipient_email]}%")
    elsif params[:subject_title].present?
      puts 'in subject_title'
      @masterlist_search = Masterlist.where('subject_title LIKE ?', "%#{params[:subject_title]}%")
    end
  end

  def masterlists_params
    params.require(:masterlist).permit(:envelope_id, :created_time, :recipient_email, :status, :recipient_type,
                                       :completed_time, :declined_time, :declined_reason, :subject_title, :auth_status,
                                       :auth_timestamp, :delivered_date_time, :note, :accesscode, :recipient_status,
                                       :rental)
  end

end

