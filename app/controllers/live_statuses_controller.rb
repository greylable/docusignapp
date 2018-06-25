class LiveStatusesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_masterlist_search, only: [:results]

  def index
  end

  def search
  end

  def results
  end

  private

  def set_masterlist_search
    if params[:envelope_id].present?
      @e_id = params[:envelope_id]
      LiveStatus.fetch_info(@e_id)
    end
  end

end