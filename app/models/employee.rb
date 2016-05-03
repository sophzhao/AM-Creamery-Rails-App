class Employee < ActiveRecord::Base
  # Callbacks
  before_save :reformat_phone
  before_validation :reformat_ssn
  before_destroy :is_destroyable?
  after_destroy :clean_up_assignment_and_shifts
  after_rollback :terminate_employee

  attr_reader :destroyable

  # Relationships
  has_many :assignments
  has_many :stores, through: :assignments
  has_one :user, dependent: :destroy
  has_many :shifts, through: :assignments
  accepts_nested_attributes_for :user, reject_if: lambda { |user| user[:email].blank? }, allow_destroy: true

  
  # Validations
  validates_presence_of :first_name, :last_name, :date_of_birth, :ssn, :role
  validates_date :date_of_birth, on_or_before: lambda { 14.years.ago }, on_or_before_message: "must be at least 14 years old"
  validates_format_of :phone, with: /\A\(?\d{3}\)?[-. ]?\d{3}[-.]?\d{4}\z/, message: "should be 10 digits (area code needed) and delimited with dashes only", allow_blank: true
  validates_format_of :ssn, with: /\A\d{3}[- ]?\d{2}[- ]?\d{4}\z/, message: "should be 9 digits and delimited with dashes only"
  validates_inclusion_of :role, in: %w[admin manager employee], message: "is not an option"
  validates_uniqueness_of :ssn
  
  # Scopes
  scope :younger_than_18, -> { where('date_of_birth > ?', 18.years.ago.to_date) }
  scope :is_18_or_older,  -> { where('date_of_birth <= ?', 18.years.ago.to_date) }
  scope :active,          -> { where(active: true) }
  scope :inactive,        -> { where(active: false) }
  scope :regulars,        -> { where(role: 'employee') }
  scope :managers,        -> { where(role: 'manager') }
  scope :admins,          -> { where(role: 'admin') }
  scope :alphabetical,    -> { order('last_name, first_name') }
  scope :for_store,       ->(store_id) { joins(:assignments).where(assignments: {store_id: store_id, end_date: nil})}



  # Other methods
  def name
    "#{last_name}, #{first_name}"
  end
  
  def proper_name
    "#{first_name} #{last_name}"
  end
  
  def current_assignment
    curr_assignment = self.assignments.select{|a| a.end_date.nil?}
    # alternative method for finding current assignment is to use scope 'current' in assignments:
    # curr_assignment = self.assignments.current    # will also return an array of current assignments
    return nil if curr_assignment.empty?
    curr_assignment.first   # return as a single object, not an array
  end
  
  def over_18?
    date_of_birth < 18.years.ago.to_date
  end
  
  def age
    (Time.now.to_s(:number).to_i - date_of_birth.to_time.to_s(:number).to_i)/10e9.to_i
  end

  # Misc Constants
  ROLES_LIST = [['Employee', 'employee'],['Manager', 'manager'],['Administrator', 'admin']]
  
  
  # Callback code  (NOT DRY!!!)
  # -----------------------------
  private
  def reformat_phone
    phone = self.phone.to_s  # change to string in case input as all numbers 
    phone.gsub!(/[^0-9]/,"") # strip all non-digits
    self.phone = phone       # reset self.phone to new string
  end

  def reformat_ssn
    ssn = self.ssn.to_s      # change to string in case input as all numbers 
    ssn.gsub!(/[^0-9]/,"")   # strip all non-digits
    self.ssn = ssn           # reset self.ssn to new string
  end

  def is_destroyable?
    @destroyable = self.shifts.past.empty?
  end

  def remove_upcoming_shifts
    @future_shifts = self.shifts.upcoming
    @future_shifts.each {|s| s.destroy} unless @future_shifts.empty?
  end

  def clean_up_assignment_and_shifts
    if @destroyable
      remove_upcoming_shifts
      self.current_assignment.delete unless self.current_assignment.nil?
    end
    @destroyable = nil
  end

  def end_current_assignment
    current_assignment = self.current_assignment    
    unless current_assignment.nil?
      current_assignment.update_attribute(:end_date, Date.current)
    end
  end

  def terminate_employee
    if !@destroyable.nil? && @destroyable == false
      remove_upcoming_shifts
      end_current_assignment
    end
    @destroyable = nil
  end

end
