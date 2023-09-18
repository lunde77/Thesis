using Gurobi
using JuMP

#************************************************************************
# input parameters (varies per day):
#La_do                      # prices down for d-1 in h 24x1
#La_up                      # prices up for d-1 in h 24x1
#Ac_do                      # activation % downwards in m 1440x1
#Ac_up                      # activation % upwards in m 1440x1
#Max_Power                  # max power of box in m 1440x1
#po_cap                     # % of resovior stored in m 1440x1
#kWh_cap                    # kWh of resovior charged in m 1440x1
#Power                      # baseline power in m 1440x1
#Connected                  # minutes where CB is connected in m 1440x1


# return (varies per day):
# value.(C_up)              # upwards bid in kW in m 1440x1
# value.(C_do)              # downwards bid in kW in m 1440x1
# value(SoC[M_d])           # the expected Energy resovior in kWh at the end of the day 1x1

function deterministic_model(La_do, La_up, Ac_do, Ac_up, Max_Power, po_cap, kWh_cap, Power, Connected, SoC_start)

   #************************************************************************
   # Static Parameters
   T = 24 # hours on a day
   M = 60 # minutes in an hour
   M_d = T*M # minutes per model, i.e. per day


   #************************************************************************
   # Model
   Mo  = Model(Gurobi.Optimizer)

   # varibles
   @variable(Mo, 0 <= Po[1:M_d])       # power delivered after activation - kW
   @variable(Mo, 0 <= C_up[1:M_d])     # Upwards bid - kW
   @variable(Mo, 0 <= C_do[1:M_d])     # Downwards bid - kW
   @variable(Mo, 0 <= Ma[1:M_d])       # Max power - kW
   @variable(Mo, 0 <= SoC[1:M_d])      # Energy resovior level - kWh

   # obejective
   @objective(Mo, Max, sum( C_up[(t-1)*60+1]*La_up[t] + C_do[(t-1)*60+1]*La_do[t] for t=1:T) )

   # bid constraiants
   @constraint(Mo, [m=1:M_d], Ma[m]-Power[m] >= C_up[m]+C_do[m]*0.2 )                # the upwards flexibility has to be greater than the the the bids regulation
   @constraint(Mo, [m=1:M_d], Power[m] >= C_up[m]*0.2+C_do[m] )                      # the downwards flexibility has to be greater than the the the bids regulation

   # Max power constraint
   @constraint(Mo, [m=1:M_d], Ma[m] <= Max_Power[m]  )                               # max charger power must be higher than max power
   for m=2:M_d
      if Connected[m] == 1 && Connected[m-1] != 0  # we need to look at m-1 for the resovior levels, as the power delivered at m, is what gives the SoC at the end
         @constraint(Mo, Ma[m] <= (kWh_cap[m-1]/po_cap[m-1]-kWh_cap[m-1] )*60  )     # the charging must not violaate the resovior max
      end
   end

   # power constraint
   @constraint(Mo, [m=1:M_d], Po[m] == Power[m]+Ac_up[m]*C_up[m]-Ac_do[m]*C_do[m])   # The power is the baseline + the activation power


   for m=1:M_d
      if Connected[m] == 0
         @constraint(Mo, SoC[m] ==  0)                                               # The SoC is to itepreted after the minutes, i.e. af after a non Connected minute, the SoC must be zero
      else
         if m ==  1
            @constraint(Mo, SoC[m] ==  SoC_start+Po[m]/60)                           # Update the SoC to have the power realized stored
            @constraint(Mo, SoC[m] <= kWh_cap[m]/po_cap[m] )                         # the SoC is not allowed to be greater or equal to the end SoC for chargin seesion
         else
            @constraint(Mo, SoC[m] ==  SoC[m-1]+Po[m]/60)                            # Update the SoC to have the power realized stored
            @constraint(Mo, SoC[m] <= kWh_cap[m]/po_cap[m] )                         # the SoC is not allowed to be greater or equal to the end SoC for chargin seesion
         end
      end
   end


   # bid cosntraints
   @constraint(Mo, [m=1:M_d],  C_up[m] <= Connected[m]*M )                           # only bid when charger is Connected
   @constraint(Mo, [m=1:M_d],  C_do[m] <= Connected[m]*M )                           # only bid when charger is Connected

   @constraint(Mo, [m=2:M, t=1:T], C_up[(t-1)*60+1] == C_up[(t-1)*60+m] )            # bid must equal for all minutes in a hour
   @constraint(Mo, [m=2:M, t=1:T], C_do[(t-1)*60+1] == C_do[(t-1)*60+m] )            # bid must equal for all minutes in a hour


   #************************************************************************
   # Solve
   solution = optimize!(Mo)
   println("Termination status: $(termination_status(Mo))")
   #************************************************************************

   if termination_status(Mo) == MOI.OPTIMAL
      println("Optimal objective value: $(objective_value(Mo))")
   else
      println("No optimal solution available")
   end
   #************************************************************************

   return value.(C_up), value.(C_do), value(SoC[M_d])
end
