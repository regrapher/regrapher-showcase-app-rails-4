class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:about]

  def about
    Regrapher.client.increment('pages.about')
  end
end