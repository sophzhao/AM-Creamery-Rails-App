namespace :db do
  desc "Erase and fill database"
  # creating a rake task within db namespace called 'populate'
  # executing 'rake db:populate' will cause this script to run
  task :populate => :environment do
    # Docs at: http://faker.rubyforge.org/rdoc/
    require 'faker'
    require 'factory_girl_rails'
    
    # Step 0: drop old databases and rebuild
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:test:prepare'].invoke
    
    # Step 1a: Add Alex as admin and user
    ae = Employee.new
    ae.first_name = "Alex"
    ae.last_name = "Heimann"
    ae.ssn = "123456789"
    ae.date_of_birth = "1993-01-25"
    ae.phone = "412-268-3259"
    ae.role = "admin"
    ae.active = true
    ae.save!
    au = User.new
    au.email = "alex@example.com"
    au.password = "creamery"
    au.password_confirmation = "creamery"
    au.employee_id = ae.id
    au.save!
    
    # Step 1b: Add Mark as employee and user
    me = Employee.new
    me.first_name = "Mark"
    me.last_name = "Heimann"
    me.ssn = "987654321"
    me.date_of_birth = "1993-01-25"
    me.phone = "412-268-8211"
    me.active = true
    me.role = "admin"
    me.save!
    mu = User.new
    mu.email = "mark@example.com"
    mu.password = "creamery"
    mu.password_confirmation = "creamery"
    mu.employee_id = me.id
    mu.save!
    
    
    # Step 2: Add some stores
    stores = {"Carnegie Mellon" => "5000 Forbes Avenue;15213", 
              "Convention Center" => "1000 Fort Duquesne Blvd;15222", 
              "Point State Park" => "101 Commonwealth Place;15222", 
              "ACAC" => "250 East Ohio;15212", 
              "Bistro" => "325 East Ohio;15212"}
    stores.each do |store|
      str = Store.new
      str.name = store[0]
      street, zip = store[1].split(";")
      str.street = street
      str.city = "Pittsburgh"
      str.state = "PA"
      str.zip = zip
      str.phone = rand(10 ** 10).to_s.rjust(10,'0')
      str.active = true
      str.save!
    end
    
    # Step 3: Add two managers for each store
    active_stores = Store.active.each do |store|
      # Add manager 
      2.times do |i|
        mgr = Employee.new
        mgr.first_name = Faker::Name.first_name
        mgr.last_name = Faker::Name.last_name
        mgr.ssn = rand(9 ** 9).to_s.rjust(9,'0')
        mgr.date_of_birth = (rand(9)+20).years.ago.to_date
        mgr.phone = rand(10 ** 10).to_s.rjust(10,'0')
        mgr.active = true
        mgr.role = "manager"
        mgr.save!
        u = User.new
        u.email = "#{mgr.first_name.downcase}.#{mgr.last_name.downcase}@example.com"
        u.password = "creamery"
        u.password_confirmation = "creamery"
        u.employee_id = mgr.id
        u.save!
        # Assign to store
        assign_mgr = Assignment.new
        assign_mgr.store_id = store.id
        assign_mgr.employee_id = mgr.id
        assign_mgr.start_date = (rand(14)+2).months.ago.to_date
        assign_mgr.end_date = nil
        assign_mgr.pay_level = [4,5].sample
        assign_mgr.save!
      end
    end
    
    # Step 4: Add some employees to the system
    store_ids = Store.all.map(&:id)
    pay_levels = [1,2,3]
    200.times do |i|
      employee = Employee.new
      # get some fake data using the Faker gem
      employee.first_name = Faker::Name.first_name
      employee.last_name = Faker::Name.last_name
      employee.role = "employee"
      employee.ssn = rand(9 ** 9).to_s.rjust(9,'0')
      employee.phone = rand(10 ** 10).to_s.rjust(10,'0')
      employee.date_of_birth = (24.years.ago.to_date..15.years.ago.to_date).to_a.sample
      employee.active = true
      employee.save!
      unless rand(6).zero?
        u = User.new
        u.email = "#{employee.first_name.downcase}.#{employee.last_name.downcase}@example.com"
        u.password = "creamery"
        u.password_confirmation = "creamery"
        u.employee_id = employee.id
        u.save!
      end
      

      # Now assign this employee to a store
      asn1 = Assignment.new
      asn1.employee_id = employee.id
      asn1.store_id = store_ids.sample 
      asn1.pay_level = pay_levels.sample 
      asn1.start_date = (2.years.ago.to_date..2.months.ago.to_date).to_a.sample
        asn1.end_date = nil
      asn1.save!

      # make some of these employees inactive
      not_active = rand(7)
      if not_active.zero?
        employee.update_attribute(:active, false)
        end_date = (7.weeks.ago.to_date..2.days.ago.to_date).to_a.sample
        asn1.update_attribute(:end_date, end_date)
      end
    end
    
    # Step 5: Add another assignment for some employees
    current_assignments = Assignment.current.for_role("employee").all
    current_assignments.each do |first_assignment|
      additional_assignments = rand(4)
      unless additional_assignments.zero?
        number_of = (2..49).to_a.sample
        asn2 = Assignment.new
          asn2.employee_id = first_assignment.employee_id
          asn2.store_id = store_ids.sample
          asn2.pay_level = first_assignment.pay_level + 1
          asn2.start_date = number_of.days.ago
          asn2.end_date = nil
        asn2.save!
      end
    end

    # Step 6: Add some jobs
    @cashier   = FactoryGirl.create(:job)
    @mopping   = FactoryGirl.create(:job, name: "Mopping")
    @making    = FactoryGirl.create(:job, name: "Ice cream making")
    @inventory = FactoryGirl.create(:job, name: "Inventory")

    # Step 7: Add some flavors
    @chocolate   = FactoryGirl.create(:flavor)
    @vanilla     = FactoryGirl.create(:flavor, name: "Vanilla")
    @strawberry  = FactoryGirl.create(:flavor, name: "Strawberry")
    @mint_chip   = FactoryGirl.create(:flavor, name: "Mint Chocolate Chip")
    @rum_raisin  = FactoryGirl.create(:flavor, name: "Rum Raisin")
    @blueberry   = FactoryGirl.create(:flavor, name: "Blueberry")

    # Step 7a: Add 4 of the 6 flavors to each store
    Store.all.each do |store|
        store_flavors = Flavor.all.to_a.sample(4)      
        store_flavors.each do |flavor|
        store_flavor = StoreFlavor.new
        store_flavor.flavor_id = flavor.id
        store_flavor.store_id = store.id
        store_flavor.save!
      end
    end

    # Step 8: Add upcoming shifts for employees
    employee_assignments = Assignment.current.for_role("employee").all
    shift_starts = ["11:00am","2:00pm","5:00pm","8:00pm"]
    employee_assignments.each do |assignment|
      has_shifts = rand(15)
      unless has_shifts == 0
        (1..6).to_a.sample.times do |i|
          shift = Shift.new
          shift.date = i.days.from_now.to_date
          shift.start_time = shift_starts.sample.to_time
          shift.assignment_id = assignment.id
          shift.save!
        end
      end
    end

    # Step 8: Add past shifts and jobs for employees
    employee_assignments = Assignment.current.for_role("employee").all
    shift_starts = ["11:00am","2:00pm","5:00pm","8:00pm"]
    employee_assignments.each do |assignment|
      has_shifts = rand(8)
      unless has_shifts == 0
        (1..6).to_a.sample.times do |i|
          shift = Shift.new
          shift.date = i.days.from_now.to_date
          shift.start_time = shift_starts.sample.to_time
          shift.assignment_id = assignment.id
          shift.save!
          shift.update_attribute(:date, (i+1).days.ago.to_date)
          unless rand(10).zero?
            shift_jobs = Job.all.to_a.sample(2)
            shift_jobs.each do |job|
              shift_job = ShiftJob.new
              shift_job.shift_id = shift.id
              shift_job.job_id = job.id
              shift_job.save!
            end
          end
        end
      end
    end
  end
end   