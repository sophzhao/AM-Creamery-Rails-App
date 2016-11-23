# 67272 Creamery Project: Phase 5, Spring 2016
---

This the 5th and final phase of the [67-272 Creamery Project](http://67272.cmuis.net/projects).  This code includes the models previously given and the tests associated with them.  There are controllers (and tests) and views, either developed previously or for this phase.

You will need to run `bundle install` to get the needed testing gems.  

You will need to add authentication support to the user model (and test it, of course).  This should be done right away as the populate script won't work without it.

You can populate the development database with realistic data by first running `rake db:populate`.  (We've added `rake db:drop`, `rake db:migrate`, `rake db:test:prepare` to the populate script so anytime you run it, it will completely reset both your dev and test databases.) This will give you five stores with over 200 employees (some active, some inactive), each having one or more assignments.  Of those some have shifts (some upcoming only, some past and upcoming) and associated jobs.  All users in the system have the same password: "creamery".

Created by Sophie Zhao, 2016
