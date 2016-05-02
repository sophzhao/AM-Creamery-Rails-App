class ShiftsController < ApplicationController
  before_action :set_shift, only: [:show, :edit, :update, :destroy]
  
  def index
    @upcoming_shifts  = Shift.upcoming.by_store.by_employee.chronological.paginate(page: params[:page]).per_page(15)
    @past_shifts = Shift.past.by_store.by_employee.chronological.paginate(page: params[:page]).per_page(15)
  end

  def show
  end

  def new
    @shift = Shift.new
  end

  def edit
  end

  def create
    @shift = Shift.new(shift_params)
    if @shift.save
      redirect_to shift_path(@shift), notice: "Shift created for #{@shift.assignment.employee.proper_name} at #{@shift.assignment.store.name}."
    else
      render action: 'new'
    end
  end

  def update
    if @shift.update(shift_params)
      redirect_to shift_params, notice: "#{@shift.assignment.employee.proper_name}'s shift at #{@shift.assignment.store.name} is updated."
    else
      render action: 'edit'
    end
  end

  def destroy
    @shift.destroy
    redirect_to shifts_path, notice: "Successfully removed #{@shift.assignment.employee.proper_name}'s shift from #{@shift.assignment.store.name}."
  end

  private
  def set_shift
    @shift = shift.find(params[:id])
  end

  def shift_params
    params.require(:shift).permit(:first_name, :last_name, :ssn, :date_of_birth, :role, :phone, :active)
  end

end