class StoresController < ApplicationController
  before_action :set_store, only: [:show, :edit, :update, :destroy]

  
  def index
    @active_stores = Store.active.alphabetical.paginate(page: params[:page]).per_page(10)
    @inactive_stores = Store.inactive.alphabetical.paginate(page: params[:page]).per_page(10)  

  end

  def show
    @current_assignments = @store.assignments.current.by_employee.paginate(page: params[:page]).per_page(8)
    authorize! :show, @store
  end

  def new
    @store = Store.new
    authorize! :new, @store
  end

  def edit
    authorize! :edit, @store
  end

  def create
    @store = Store.new(store_params)
    authorize! :create, @store
    if @store.save
      redirect_to store_path(@store), notice: "Successfully created #{@store.name}."
    else
      render action: 'new'
    end
  end

  def update
    authorize! :update, @store
    if @store.update(store_params)
      redirect_to store_path(@store), notice: "Successfully updated #{@store.name}."
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :destroy, @store
    @store.destroy
    redirect_to stores_path, notice: "Successfully removed #{@store.name} from the AMC system."
  end

  private
  def set_store
    @store = Store.find(params[:id])
  end

  def store_params
    params.require(:store).permit(:name, :street, :city, :state, :zip, :phone, :active)
  end

end