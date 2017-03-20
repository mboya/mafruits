class HomeController < ApplicationController
  def index
    @fruits = Fruit.all.order(name: :asc)
  end
end
