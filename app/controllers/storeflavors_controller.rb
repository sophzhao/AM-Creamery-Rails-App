class StoreFlavorsController < ApplicationController
  before_action :set_store_flavor, only: [:show, :edit, :update, :destroy]
  
  def index
    @store_flavors_store = StoreFlavor.for_store(@store.id).alphabetical
    @store_flavors_flavor = StoreFlavor.for_flavor(@flavor.id).alphabetical
  end

  def show
  end

  def new
    @store_flavor = StoreFlavor.new
    authorize! :new, @store_flavor
  end

  def edit
  end

  def create
    @store_flavor = StoreFlavor.new(store_flavor_params)
    authorize! :create, @store_flavor
    if @store_flavor.save
      redirect_to store_flavor_path(@store_flavor), notice: "Successfully created #{@store_flavor.name}."
    else
      render action: 'new'
    end
  end

  def update
    authorize! :update, @store_flavor
    if @store_flavor.update(store_flavor_params)
      redirect_to store_flavor_path(@store_flavor), notice: "Successfully updated #{@store_flavor.name}."
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :destroy, @store_flavor
    @store_flavor.destroy
    redirect_to store_flavors_path, notice: "Successfully removed #{@store_flavor.name} from the AMC system."
  end

  private
  def set_store_flavor
    @store_flavor = StoreFlavor.find(params[:id])
  end

  def store_flavor_params
    params.require(:store_flavor).permit(:store_id, :flavor_id)
  end

end