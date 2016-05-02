require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase
  # Test that don't save the attraction to the database as a blank value
  should accept_nested_attributes_for(:attractions).allow_destroy(true)

  # Test relationships
  should have_many(:assignments)
  should have_many(:stores).through(:assignments)
  should have_many(:shifts).through(:assignments)
  should have_one(:user).dependent(:destroy)
  
  # Test basic validations
  should validate_presence_of(:first_name)
  should validate_presence_of(:last_name)
  should validate_presence_of(:ssn)
  should validate_presence_of(:role)
  should validate_presence_of(:date_of_birth)
  # tests for phone
  should allow_value("4122683259").for(:phone)
  should allow_value("412-268-3259").for(:phone)
  should allow_value("412.268.3259").for(:phone)
  should allow_value("(412) 268-3259").for(:phone)
  should allow_value(nil).for(:phone)
  should_not allow_value("2683259").for(:phone)
  should_not allow_value("14122683259").for(:phone)
  should_not allow_value("4122683259x224").for(:phone)
  should_not allow_value("800-EAT-FOOD").for(:phone)
  should_not allow_value("412/268/3259").for(:phone)
  should_not allow_value("412-2683-259").for(:phone)
  # tests for ssn
  should allow_value("123456789").for(:ssn)
  should_not allow_value("12345678").for(:ssn)
  should_not allow_value("1234567890").for(:ssn)
  should_not allow_value("bad").for(:ssn)
  should_not allow_value(nil).for(:ssn)
  # test date_of_birth
  should allow_value(17.years.ago.to_date).for(:date_of_birth)
  should allow_value(15.years.ago.to_date).for(:date_of_birth)
  should allow_value(14.years.ago.to_date).for(:date_of_birth)
  should_not allow_value(13.years.ago).for(:date_of_birth)
  should_not allow_value("bad").for(:date_of_birth)
  should_not allow_value(nil).for(:date_of_birth)
  # tests for role
  should allow_value("admin").for(:role)
  should allow_value("manager").for(:role)
  should allow_value("employee").for(:role)
  should_not allow_value("bad").for(:role)
  should_not allow_value("hacker").for(:role)
  should_not allow_value(10).for(:role)
  should_not allow_value("vp").for(:role)
  should_not allow_value(nil).for(:role)

  context "Creating a context for employees" do
    # create the objects I want with factories
    setup do 
      create_employees
    end
    
    # and provide a teardown method as well
    teardown do
      remove_employees
    end
  
    # now run the tests:
    # test employees must have unique ssn
    should "force employees to have unique ssn" do
      repeat_ssn = FactoryGirl.build(:employee, first_name: "Steve", last_name: "Crawford", ssn: "084-35-9822")
      deny repeat_ssn.valid?
    end
    
    # test scope younger_than_18
    should "show there are two employees under 18" do
      assert_equal 2, Employee.younger_than_18.size
      assert_equal ["Crawford", "Wilson"], Employee.younger_than_18.map{|e| e.last_name}.sort
    end
    
    # test scope younger_than_18
    should "show there are four employees over 18" do
      assert_equal 4, Employee.is_18_or_older.size
      assert_equal ["Gruberman", "Heimann", "Janeway", "Sisko"], Employee.is_18_or_older.map{|e| e.last_name}.sort
    end
    
    # test the scope 'active'
    should "shows that there are five active employees" do
      assert_equal 5, Employee.active.size
      assert_equal ["Crawford", "Gruberman", "Heimann", "Janeway", "Sisko"], Employee.active.map{|e| e.last_name}.sort
    end
    
    # test the scope 'inactive'
    should "shows that there is one inactive employee" do
      assert_equal 1, Employee.inactive.size
      assert_equal ["Wilson"], Employee.inactive.map{|e| e.last_name}.sort
    end
    
    # test the scope 'regulars'
    should "shows that there are 3 regular employees: Ed, Cindy and Ralph" do
      assert_equal 3, Employee.regulars.size
      assert_equal ["Crawford","Gruberman","Wilson"], Employee.regulars.map{|e| e.last_name}.sort
    end
    
    # test the scope 'managers'
    should "shows that there are 2 managers: Ben and Kathryn" do
      assert_equal 2, Employee.managers.size
      assert_equal ["Janeway", "Sisko"], Employee.managers.map{|e| e.last_name}.sort
    end
    
    # test the scope 'admins'
    should "shows that there is one admin: Alex" do
      assert_equal 1, Employee.admins.size
      assert_equal ["Heimann"], Employee.admins.map{|e| e.last_name}.sort
    end
    
    # test the method 'name'
    should "shows name as last, first name" do
      assert_equal "Heimann, Alex", @alex.name
    end   
    
    # test the method 'proper_name'
    should "shows proper name as first and last name" do
      assert_equal "Alex Heimann", @alex.proper_name
    end 
    
    # test the method 'current_assignment'
    should "shows return employee's current assignment if it exists" do
      create_stores
      create_assignments
      # person with a current assignment
      assert_equal @assign_cindy, @cindy.current_assignment # only 1 assignment ever
      assert_equal @promote_ben, @ben.current_assignment # 2 assignments, returns right one
      # person had assignments but has no current assignment
      assert_nil @ed.current_assignment
      @assign_cindy.update_attribute(:end_date, Date.current)
      @cindy.reload
      assert_nil @cindy.current_assignment
      # person with no assignments ever has no current assignment
      assert_nil @alex.current_assignment
      remove_assignments
      remove_stores
    end
    
    # test the callback is working 'reformat_ssn'
    should "shows that Cindy's ssn is stripped of non-digits" do
      assert_equal "084359822", @cindy.ssn
    end
    
    # test the callback is working 'reformat_phone'
    should "shows that Ben's phone is stripped of non-digits" do
      assert_equal "4122682323", @ben.phone
    end
    
    # test the method 'over_18?'
    should "shows that over_18? boolean method works" do
      assert @ed.over_18?
      deny @cindy.over_18?
    end
    
    # test the method 'age'
    should "shows that age method returns the correct value" do
      assert_equal 19, @ed.age
      assert_equal 17, @cindy.age
      assert_equal 30, @kathryn.age
    end   

    # test that a model knows which employees are destroyable
    should "recognize when an employee is destroyable" do 
      create_stores
      create_assignments
      create_shifts
      deny @kathryn.destroy,"#{@kathryn.shifts.upcoming.count}"
      assert @cindy.destroy
      remove_stores
      remove_assignments
      remove_shifts
    end

    # employee w/ past shifts is properly terminated
    should "properly handle case of employee with past shifts" do 
      create_stores
      create_assignments
      create_shifts
      kathryn_id = @kathryn.id
      deny Assignment.current.for_employee(kathryn_id).empty?
      deny Shift.past.for_employee(kathryn_id).empty?
      deny Shift.upcoming.for_employee(kathryn_id).empty?
      deny @kathryn.destroy
      assert_equal Date.current, @kathryn.assignments.chronological.first.end_date
      assert Shift.upcoming.for_employee(kathryn_id).empty?
      remove_stores
      remove_assignments
      remove_shifts
    end

    # employee w/o past shifts is properly terminated
    should "properly handle case of employee with no past shifts" do 
      create_stores
      create_assignments
      create_upcoming_shifts
      cindy_id = @cindy.id
      deny Assignment.current.for_employee(cindy_id).empty?
      deny Shift.upcoming.for_employee(cindy_id).empty?
      assert @cindy.destroy
      deny Employee.exists?(cindy_id)
      assert Assignment.current.for_employee(cindy_id).empty?
      assert Shift.upcoming.for_employee(cindy_id).empty?
      remove_stores
      remove_assignments
      remove_upcoming_shifts
    end

  end
end
