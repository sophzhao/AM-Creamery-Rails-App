67272 Creamery Project: Phase 5 Starter
---

This is the starter code for Phase 5 of the [67-272 Creamery Project](http://67272.cmuis.net/projects).  This starter code includes the models previously given and the tests associated with them.  There are controllers (and tests) but no views since views are irrelevant this phase.

You will need to run `bundle install` to get the needed testing gems.  

You will need to add authentication support to the user model (and test it, of course).  This should be done right away as the populate script won't work without it.

You can populate the development database with realistic data by first running `rake db:populate`.  (We've added `rake db:drop`, `rake db:migrate`, `rake db:test:prepare` to the populate script so anytime you run it, it will completely reset both your dev and test databases.) This will give you five stores with over 200 employees (some active, some inactive), each having one or more assignments.  Of those some have shifts (some upcoming only, some past and upcoming) and associated jobs.  All users in the system have the same password: "creamery".

This phase will take substantially longer than phase 3 and it is recommended that students start early.  

As always, should you or any of your I.M. Force be caught or killed, the Secretary will disavow any knowledge of your actions.  This message will self-destruct in five seconds. Good luck.# AM-Creamery-Rails-App
