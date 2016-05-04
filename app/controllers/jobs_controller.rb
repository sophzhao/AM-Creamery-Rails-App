class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy]
  
  def index
    @jobs = Job.alphabetical
  end

  def show
  end

  def new
    @job = Job.new
    authorize! :new, @job
  end

  def edit
  end

  def create
    @job = Job.new(job_params)
    authorize! :create, @job
    if @job.save
      redirect_to job_path(@job), notice: "Successfully created #{@job.name}."
    else
      render action: 'new'
    end
  end

  def update
    authorize! :update, @job
    if @job.update(job_params)
      redirect_to job_path(@job), notice: "Successfully updated #{@job.name}."
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :destroy, @job
    @job.destroy
    redirect_to jobs_path, notice: "Successfully removed #{@job.name} from the AMC system."
  end

  private
  def set_job
    @job = Job.find(params[:id])
  end

  def job_params
    params.require(:job).permit(:name, :description)
  end

end