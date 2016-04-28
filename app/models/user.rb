class User < ActiveRecord::Base
  # get modules to help with some functionality
  include CreameryHelpers::Validations
  has_secure_password

  # Relationships
  belongs_to :employee

  # Validations
  validates_uniqueness_of :email, case_sensitive: false
  validates_format_of :email, :with => /\A[\w]([^@\s,;]+)@(([\w-]+\.)+(com|edu|org|net|gov|mil|biz|info))\z/i, :message => "is not a valid format"
  validate :employee_is_active_in_system
  
  private
  def employee_is_active_in_system
    is_active_in_system(:employee)
  end

  def self.authenticate(email,password)
    find_by_email(email).try(:authenticate, password)
  end

end
