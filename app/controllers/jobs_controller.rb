class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy]
  
  def index
  end

  def show
  end

  def new
    @job = Job.new
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
  def set_job
    @job = job.find(params[:id])
  end

  def job_params
    params.require(:job).permit(:first_name, :last_name, :ssn, :date_of_birth, :role, :phone, :active)
  end

end