class FunFactsController < ApplicationController
  def show
    season = Season.find_by(year: (params[:year] || Season.maximum(:year)))
    fun_facts = FunFact.new(season:)

    render :show, locals: { season:, fun_facts: }
  end
end
