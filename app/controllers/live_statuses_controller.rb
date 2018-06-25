class LiveStatusesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_masterlist_search, only: [:results]

  def index
  end

  def search
  end

  def results
  end

  def select_multiple
    if params[:commit] == "Download selected"
      if params[:live_status].present?
        @envelope_rental = params[:live_status]
        @array_try = ""
        @envelope_rental.each { |k,v| @array_try << k}
        @final_array = @array_try.split(',')
        download_zip(@final_array)
      end
    end
  end

  def download_zip(envelope_rental)
    require 'rubygems'
    require 'zip'
    LiveStatus.docu_auth
    compressed_filestream = Zip::OutputStream.write_buffer do |stream|
      related_data = LiveStatus.get_doc(envelope_rental)
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
    compressed_filestream.rewind
    send_data compressed_filestream.read, filename: "contracts.zip"
  end

  private

  def set_masterlist_search
    if params[:envelope_id].present?
      @e_id = params[:envelope_id]
      @livestatus = LiveStatus.fetch_info(@e_id)
    elsif
      redirect_to search_live_statuses_path, notice: 'Search Request Cannot Be Blank!'
    end
  end

end