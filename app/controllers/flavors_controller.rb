class FlavorsController < ApplicationController
  before_action :set_flavor, only: [:show, :edit, :update, :destroy]
  
  def index
    @flavors = Flavor.alphabetical
    @active_flavors = Flavor.active.alphabetical
    @inactive_flavors = Flavor.inactive.alphabetical
  end

  def show
  end

  def new
    @flavor = Flavor.new
    authorize! :new, @flavor
  end

  def edit
  end

  def create
    @flavor = Flavor.new(flavor_params)
    authorize! :create, @flavor
    if @flavor.save
      redirect_to flavor_path(@flavor), notice: "Successfully created #{@flavor.name}."
    else
      render action: 'new'
    end
  end

  def update
    authorize! :update, @flavor
    if @flavor.update(flavor_params)
      redirect_to flavor_path(@flavor), notice: "Successfully updated #{@flavor.name}."
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :destroy, @flavor
    @flavor.destroy
    redirect_to flavors_path, notice: "Successfully removed #{@flavor.name} from the AMC system."
  end

  private
  def set_flavor
    @flavor = Flavor.find(params[:id])
  end

  def flavor_params
    params.require(:flavor).permit(:name, :active)
  end

end