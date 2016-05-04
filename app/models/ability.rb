class Ability
  include CanCan::Ability

  def initialize(user)
    # set user to new User if not logged in
    user ||= User.new # i.e., a guest user

    if user.role? :admin
      can :manage, :all

    elsif user.role? :manager
      can :read, Store

      can :read, Job

      can :read, Flavor
      
      #can read the employees at the same current store as manager
      can :read, Employee do |this_employee|
        my_store = user.employee.current_assignment.store_id
        this_employee.current_assignment.store_id == my_store
      end

      #can read the assignments at the same current store as manager
      can :read, Assignment do |this_assignment|
        my_store = user.employee.current_assignment.store_id
        managed_assignments = Assignment.current.map{|a| a.store_id if a.store_id == my_store}
        managed_assignments.include? this_assignment
      end

      #can read the shifts at the same current store as manager
      can :read, Shift do |this_shift|
        my_store = user.employee.current_assignment.store_id 
        managed_shifts = Assignment.current.map{|a| a.shifts if a.store_id == my_store}
        managed_shifts.include? this_shift
      end

      can :create, Shift do |this_shift|
        my_store = user.employee.current_assignment.store_id 
        # user.employee.current_assignment.store_id == this_shift.assignment.store_id && user.e == this_shift.assignment.employee_id
        the_shifts = Assignment.current.map{|a| a.shifts if a.store_id == my_store}
        the_shifts.include? this_shift        
      end

      can :update, Shift do |this_shift|
        my_store = user.employee.current_assignment.store_id         
        the_shifts = Assignment.current.map{|a| a.shifts if a.store_id == my_store}
        the_shifts.include? this_shift                
      end

      can :destroy, Shift do |this_shift|
        my_store = user.employee.current_assignment.store_id         
        the_shifts = Assignment.current.map{|a| a.shifts if a.store_id == my_store}
        the_shifts.include? this_shift 
      end

      can :create, ShiftJob do |this_shift_job| 
        user.employee.current_assignment.store_id == this_shift_job.shift.assignment.store_id 
      end 

      can :destroy, ShiftJob do |this_shift_job| 
        user.employee.current_assignment.store_id == this_shift_job.shift.assignment.store_id
      end

      can :create, StoreFlavor do |this_store_flavor| 
        user.employee.current_assignment.store_id == this_store_flavor..store_id 
      end 

      can :destroy, StoreFlavor do |this_store_flavor| 
        user.employee.current_assignment.store_id == this_store_flavor.shift.assignment.store_id
      end


    elsif user.role? :employee
      can :read, Job, :active => true
      can :read, Store, :active => true
      can :read, Flavor, :active => true
      can :start_shift, Shift
      can :end_shift, Shift

      can :read, Employee do |this_employee|
        this_employee.id == user.employee_id
      end

      can :read, User do |u|
        u.id == user.id
      end

      can :read, Assignment do |a|
        my_assignments = user.employee.assignment.map(&:id)
        my_assignments.include? a
      end

      can :read, Shift do |s|
        my_shifts = user.employee.assignment.shift.map(&:id)
        my_shifts.include? s
      end

      can :read, ShiftJob do |sj|
        my_shift_jobs = user.employee.assignment.shift.shift_job.map(&:id)
        my_shift_jobs.include? sj
      end

      can :update, Employee do |this_employee|
        this_employee.id == user.id
      end

      can :update, Shift do |s|
        s.employee.id == user.employee.id
      end

      can :update, User do |u|
        u.id == user.id
      end
    else
      can :read, Store do |s|
        active_stores = Store.active.map(&:id)
        active_stores.include? s
      end
    end
  end
end


    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities



