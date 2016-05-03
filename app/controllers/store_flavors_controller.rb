class StoreFlavorsController < ApplicationController
  before_action :set_store_flavor, only: [:show, :edit, :update, :destroy]
  
  def index
  end

  def show
    @active_store_flavors = Flavor.find(StoreFlavor.flavor.active.flavor_id)
    @stores_flavors = Flavor.find(StoreFlavor.for_store(@store.id).flavor_id)
  end

  def new
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
  def set_store_flavor
    @store_flavor = StoreFlavor.find(params[:id])
  end

  def store_flavor_params
    params.require(:flavor).permit(:store_id, :flavor_id)
  end

end