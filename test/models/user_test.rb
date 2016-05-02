require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should belong_to(:employee)

  # Validating email...
  should allow_value("fred@fred.com").for(:email)
  should allow_value("fred@andrew.cmu.edu").for(:email)
  should allow_value("my_fred@fred.org").for(:email)
  should allow_value("fred123@fred.gov").for(:email)
  should allow_value("my.fred@fred.net").for(:email)
  
  should_not allow_value("fred").for(:email)
  should_not allow_value("fred@fred,com").for(:email)
  should_not allow_value("fred@fred.uk").for(:email)
  should_not allow_value("my fred@fred.com").for(:email)
  should_not allow_value("fred@fred.con").for(:email)

  should validate_uniqueness_of(:email).case_insensitive

  context "Creating a context for users" do
    setup do 
      create_employees
      create_users
    end
    
    teardown do
      remove_employees
      remove_users
    end

    should "shows that only active employees can have users" do
      # demonstrate an active employee with an associated user
      assert @alex.active
      assert_not_nil @alex_user
      # test an inactive employee can't have a user
      @inactive = FactoryGirl.build(:user, employee: @ralph)
      deny @inactive.valid?
      # test a non-existent employee can't have a user
      @ghost = FactoryGirl.build(:employee)
      assert @ghost.valid?
      @ghost_user = FactoryGirl.build(:user, employee: @ghost)
      deny @ghost_user.valid?
    end

    # not necessary, but prove the user is destroyed if employee destroyed;
    # was really handled by dependent: :destroy in employee model and its test
    should "destroy user if employee destroyed" do
      freeman = FactoryGirl.create(:employee, first_name: "Melanie", last_name: "Freeman", date_of_birth: 229.months.ago.to_date, role: "manager", phone: nil, ssn: "084359855")
      freeman_user = FactoryGirl.create(:user, employee: freeman, email: "mdf@example.com")
      freeman_user.reload
      assert_equal "mdf@example.com", freeman_user.email
      assert freeman.destroy
      assert freeman_user.destroyed?
    end

    # test role? method
    should "have working role? method" do 
      assert @ben_user.role?(:manager)
      deny @ben_user.role?(:admin)
      assert @alex_user.role?(:admin)
    end
    
  end
end
