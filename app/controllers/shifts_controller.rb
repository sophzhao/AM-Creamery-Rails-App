class ShiftsController < ApplicationController
  before_action :set_shift, only: [:show, :edit, :update, :destroy, :start_shift, :end_shift]
  

  def index
    if current_user.role? :admin
      @upcoming_shifts  = Shift.upcoming.by_store.by_employee.paginate(page: params[:page]).per_page(15)
      @past_shifts = Shift.past.by_store.by_employee.paginate(page: params[:page]).per_page(15)
      @incomplete_shifts = Shift.incomplete.by_employee.paginate(page: params[:page]).per_page(15)
      @completed_shifts = Shift.completed.by_employee.paginate(page: params[:page]).per_page(15)
    elsif current_user.role? :manager
      @upcoming_shifts  = Shift.upcoming.for_store(current_user.employee.current_assignment.store_id).by_employee.paginate(page: params[:page]).per_page(15)
      @past_shifts = Shift.past.for_store(current_user.employee.current_assignment.store_id).by_employee.paginate(page: params[:page]).per_page(15)
      @incomplete_shifts = Shift.incomplete.for_store(current_user.employee.current_assignment.store_id).by_employee.paginate(page: params[:page]).per_page(15)
      @completed_shifts = Shift.completed.for_store(current_user.employee.current_assignment.store_id).by_employee.paginate(page: params[:page]).per_page(15)
    elsif current_user.role? :employee
      @upcoming_shifts  = Shift.upcoming.for_employee(current_user.employee_id).paginate(page: params[:page]).per_page(15)
      @past_shifts = Shift.past.for_employee(current_user.employee_id).chronological.paginate(page: params[:page]).per_page(15)
    end
    if params[:shift_type] == "upcoming"
      @shifts = @upcoming_shifts 
      @state = "upcoming"
    elsif params[:shift_type] == "past"
      @shifts = @past_shifts
      @state = "past"
    elsif params[:shift_type] == "incomplete"
      @shifts = @incomplete_shifts
      @state = "incomplete"
    else
      @shifts = @completed_shifts
      @state = "completed"
    end
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

  def start_shift  
    @shift.start_now
    @shift.save
    redirect_to home_path, notice: "#{@shift.assignment.employee.proper_name}'s shift at #{@shift.assignment.store.name} is started."
  end

  def end_shift 
    @shift.end_now
    @shift.save
    redirect_to home_path, notice: "#{@shift.assignment.employee.proper_name}'s shift at #{@shift.assignment.store.name} has ended."    
  end

  def destroy
    @shift.destroy
    redirect_to shifts_path, notice: "Successfully removed #{@shift.assignment.employee.proper_name}'s shift from #{@shift.assignment.store.name}."
  end

  private
  def set_shift
    @shift = Shift.find(params[:id])
  end

  def shift_params
    params.require(:shift).permit(:assignment_id, :date, :start_time, :end_time, :notes, :job_ids => [])
  end

end