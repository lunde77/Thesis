using Gurobi
using JuMP

#************************************************************************
# input parameters (varies per day):
#La_do                      # prices down for d-1 in h 24xS
#La_up                      # prices up for d-1 in h 24xS
#Ac_do                      # activation % downwards in m 1440xS
#Ac_up                      # activation % upwards in m 1440xS
#Power_rate                 # charging power rate of box in m 1440xIxS
#po_cap                     # % of resovior stored in m 1440xIxS
#kWh_cap                    # kWh of resovior charged in m 1440xIxS
#Power                      # baseline power in m 1440xIxS
#Connected                  # minutes where CB is connected in m 1440xIxS
# SoC_start                 # Start SoC for each CB to each scenario IxS
# SoC_A_cap                 # The aggregated SoC without activation MxS
# I                         # Number of charge boxses

# return (varies per day):
# value.(C_up)              # upwards bid for aggregator in kW in m 1440x1
# value.(C_do)              # downwards bid for aggregator in kW in m 1440x1
# value.(C_do_I)            # distributed of upwards bid in kW in m 1440xI
# value.(C_do_I)         # distributed of downwards bid in kW in m 1440xI
# value.(SoC[M_d,:])        # the expected Energy resovior in kWh at the end of the day 1xI
# value.(SoC_A)             # the expected Energy resovior in kWh for all minutes for the aggregated resovior
# value.(Ma_A)              # the expected Ma charging rate for the aggregator
# objective_value(Mo)       # The expected net ernings after pentalty

function Stochastic_d1_model(La_do, La_up, Ac_do, Ac_up, Power_rate, po_cap, kWh_cap, Power, Connected, SoC_start, SoC_A_cap, I, S)


   println("er kommer herind ")

   #************************************************************************
   # Static Parameters
   T = 24 # hours on a day
   M = 60 # minutes in an hour
   M_d = T*M # minutes per model, i.e. per day
   RM = 1 # %-end SoC assumed
   pen = 100000000000000 # penalty per kWh of missed activation
   Pi = 1/S

   #************************************************************************
   # Model
   Mo  = Model(Gurobi.Optimizer)

   # varible per individual CB
   @variable(Mo, 0 <= Po[1:M_d, 1:I, s=1:S])          # Power delivered after activation - kW
   @variable(Mo, 0 <= Ma[1:M_d, 1:I, s=1:S])          # Max power - kW
   @variable(Mo, 0 <= SoC[1:M_d, 1:I, s=1:S])         # Simulated Energy resovior level after activation - kWh
   @variable(Mo, 0 <= Ap_do_I[1:M_d, 1:I, s=1:S])     # failed activation per CB per S
   @variable(Mo, 0 <= Ap_up_I[1:M_d, 1:I, s=1:S])     # failed activation per CB per S
   @variable(Mo, 0 <= C_do_I[1:M_d, 1:I, s=1:S])      # amount of downregulation distributed on CB on given scenario
   @variable(Mo, 0 <= C_up_I[1:M_d, 1:I, s=1:S])      # amount of upregulation distributed on CB on given scenario

   # varible for aggregator
   @variable(Mo, 0 <= Po_A[1:M_d, s=1:S])             # aggregator Power delivered after activation - kW
   @variable(Mo, 0 <= Power_A[1:M_d, s=1:S])          # aggregator Power delivered before activation - kW
   @variable(Mo, 0 <= Flex_up[1:M_d, s=1:S])          # aggregator Upwards bid for scenario s - kW
   @variable(Mo, 0 <= Flex_do[1:M_d, s=1:S])          # aggregator Downwards bid for scenario s  - kW
   @variable(Mo, 0 <= Ma_A[1:M_d, s=1:S])             # aggregator Max power - kW
   @variable(Mo, 0 <= SoC_A[1:M_d, s=1:S])            # aggregator SoC for two scenarios in case of no activation

   # Bid Varible
   @variable(Mo, 0 <= C_up[1:M_d])                    # Chosen upwards bid
   @variable(Mo, 0 <= C_do[1:M_d])                    # Chosen downwards bid
   @variable(Mo, 0 <= Ap_up[1:M_d, 1:S])              # Total failed upwards activation
   @variable(Mo, 0 <= Ap_do[1:M_d, 1:S])              # Total failed downwards activation

   # Objetives
   @variable(Mo, Income)                         # Total income on capacity
   @variable(Mo, 0 <= Penalty)                        # Total penalty based on missied activation

   ### Obejective ###
   @objective(Mo, Max,  Income-Penalty)

   # summerizing constraints
   @constraint(Mo, Income == sum( (C_up[(t-1)*60+1]*La_up[t,s] + C_do[(t-1)*60+1]*La_do[t,s])*Pi for t=1:T, s=1:S) )
   @constraint(Mo, Penalty == sum( (Ap_up[(t-1)*60+1,s]*pen+Ap_do[(t-1)*60+1,s]*pen )*Pi for t=1:T, s=1:S) )

   @constraint(Mo, Income-Penalty <= 1000000)

   ### Bid constraints ###
   # Aggregator Bid constraiants
   @constraint(Mo, [m=1:M_d, s=1:S], C_up[m] == sum(C_up_I[m,i,s] for i=1:I) )                                    # The upwards bid must be distributed over the charge boxses
   @constraint(Mo, [m=1:M_d, s=1:S], C_do[m] == sum(C_do_I[m,i,s] for i=1:I) )                                    # The downwards bid must be distributed over the charge boxses

   @constraint(Mo, [m=1:M_d, s=1:S], Ap_up[m,s] == sum(Ap_up_I[m,i,s] for i=1:I)/60 )                             # The pentalty for not meeeting potential activation energy
   @constraint(Mo, [m=1:M_d, s=1:S], Ap_do[m,s] == sum(Ap_do_I[m,i,s] for i=1:I)/60 )                             # The pentalty for not meeeting potential activation energy

   @constraint(Mo, [m=2:M, t=1:T], C_up[(t-1)*60+1] == C_up[(t-1)*60+m] )                                         # Bid must equal for all minutes in a hour
   @constraint(Mo, [m=2:M, t=1:T], C_do[(t-1)*60+1] == C_do[(t-1)*60+m] )                                         # Bid must equal for all minutes in a hour

   #@constraint(Mo, [m=1:M_d, s=1:S], Ma_A[m,s]-Power_A[m,s] >= C_do[m] )                                          # The upwards flexibility has to be greater than the the the bids regulation
   #@constraint(Mo, [m=1:M_d, s=1:S], Power_A[m,s] >= C_do[m]*0.2+C_up[m] )                                        # The downwards flexibility has to be greater than the the the bids regulation, hence there is delay factor added on
   #@constraint(Mo, [m=1:M_d, s=1:S], SoC_A_cap[m,s]-SoC_A[m,s] >= C_do[m]*(1/3) )                                 # There must at all times be enough resovior to be activated for 20 minutes of the - this is a

   ### Operation constraints ###
   # energy related power constraint
   @constraint(Mo, [m=1:M_d, i=1:I, s=1:S], Po[m,i,s] == Power[m,i,s]-Ac_up[m,s]*(C_do_I[m,i,s]-Ap_do_I[m,i,s])
                                                                  +Ac_do[m,s]*(C_do_I[m,i,s]-Ap_up_I[m,i,s])  )   # The power is the baseline + the sum activation power
   @constraint(Mo, [m=1:M_d, i=1:I, s=1:S], Po[m,i,s] <= Ma[m,i,s])                                               # The realized power must be smaller or equal to max power

   # Activation power constraint - these almost mimics the constraints above, however down and upwards activation within the same minute, can cancel out, and thus not mimic the actial flexibility needed to be delivered, hence the constraints below
   @constraint(Mo, [m=1:M_d, i=1:I, s=1:S], Ac_up[m,s]*(C_do_I[m,i,s]-Ap_do_I[m,i,s]) <= Power[m,i,s])            # The upwards regulation delivered must be smaller than the power had + the potential penalty
   @constraint(Mo, [m=1:M_d, i=1:I, s=1:S], Ac_do[m,s]*(C_do_I[m,i,s]-Ap_up_I[m,i,s]) <=  Ma[m,i,s])              # The downwards regulation delivered must smaller than the max effect + the potential penalty

   # Max power constraint
   @constraint(Mo, [m=1:M_d, i=1:I, s=1:S], Ma[m,i,s] <= Power_rate[m,i,s]*Connected[m,i,s]  )                    # The charging power rate of the box must be higher than the Max power (Ma)
   for i=1:I
      for m=2:M_d
         for s=1:S
            if Connected[m,i,s] == 1 && Connected[m-1,i,s] != 0  # We need to look at m-1 for the resovior levels, as the power delivered at m, is what gives the SoC at the end
               @constraint(Mo, Ma[m,i,s] <= (kWh_cap[m-1,i,s]/po_cap[m-1,i,s]-SoC[m-1,i,s]/RM )*60  )             # The charging must not violaate the resovior max
            end
         end
      end
   end

   # SoC constraint
   for i=1:I
      for m=1:M_d
         for s=1:S
            if Connected[m,i,s] == 0
               @constraint(Mo, SoC[m,i,s] ==  0)                                                                     # The SoC is to itepreted after the minutes, i.e. af after a non Connected minute, the SoC must be zero
            else
               if m ==  1
                  @constraint(Mo, SoC[m,i,s] ==  SoC_start[i,s]+Po[m,i,s]/60)                                        # Update the SoC to have the power realized stored
                  @constraint(Mo, SoC[m,i,s] <= kWh_cap[m,i,s]/po_cap[m,i,s]/RM )                                    # The SoC is not allowed to be greater or equal to the end SoC for chargin seesion
               else
                  @constraint(Mo, SoC[m,i,s] ==  SoC[m-1,i,s]+Po[m,i,s]/60)                                          # Update the SoC to have the power realized stored
                  @constraint(Mo, SoC[m,i,s] <= kWh_cap[m,i,s]/po_cap[m,i,s]/RM )                                    # The SoC is not allowed to be greater or equal to the end SoC for chargin seesion
               end
            end
         end
      end
   end

   ### aggregator helper varibles ###
   @constraint(Mo, [m=1:M_d, s=1:S], Ma_A[m,s] == sum(Ma[m,i,s] for i=1:I) )                                      # The maximum charge is the sum of all max charging rates
   @constraint(Mo, [m=1:M_d, s=1:S], Po_A[m,s] == sum(Po[m,i,s] for i=1:I) )                                      # The power delivered for the aggregator is the sum of all
   @constraint(Mo, [m=1:M_d, s=1:S], Power_A[m,s] == sum(Power[m,i,s] for i=1:I) )                                # The power delivered for the aggregator is the sum of all
   @constraint(Mo, [m=1:M_d, s=1:S], SoC_A[m,s] == sum(kWh_cap[m,i,s] for i=1:I))                                 # The aggregator SoC if no activation is realized


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

   return value.(C_up), value.(C_do), value.(C_do_I), value.(C_do_I), value.(Power_A), value.(Ma_A), value.(SoC_A), value.(Ap_up), value.(Ap_do), value(Penalty)
end
