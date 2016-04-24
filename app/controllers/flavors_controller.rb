class FlavorsController < ApplicationController
  before_action :set_flavor, only: [:show, :edit, :update, :destroy]
  
  def index
  end

  def show
  end

  def new
    @flavor = Flavor.new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end

  private
  def set_flavor
    @flavor = flavor.find(params[:id])
  end

  def flavor_params
    params.require(:flavor).permit(:first_name, :last_name, :ssn, :date_of_birth, :role, :phone, :active)
  end

end