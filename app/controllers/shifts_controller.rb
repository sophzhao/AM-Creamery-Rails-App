class ShiftsController < ApplicationController
  before_action :set_shift, only: [:show, :edit, :update, :destroy]
  
  def index
  end

  def show
  end

  def new
    @shift = Shift.new
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
  def set_shift
    @shift = shift.find(params[:id])
  end

  def shift_params
    params.require(:shift).permit(:first_name, :last_name, :ssn, :date_of_birth, :role, :phone, :active)
  end

end