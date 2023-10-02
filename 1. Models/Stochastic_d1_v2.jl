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
# value.(C_up_I)            # distributed of upwards bid in kW in m 1440xI
# value.(C_do_I)            # distributed of downwards bid in kW in m 1440xI
# value.(Power_A)           # The aggregated power without activation for each scenario 1440xIxS
# value.(SoC[M_d,:])        # the expected Energy resovior in kWh at the end of the day 1xI
# value.(SoC_A)             # the expected Energy resovior in kWh for all minutes for the aggregated resovior
# value.(Ma_A)              # the expected Ma charging rate for the aggregator
# objective_value(Mo)       # The expected net ernings after pentalty

function Stochastic_d1_model(La_do, La_up, Ac_do, Ac_up, Power_rate, po_cap, kWh_cap, Power, Connected, SoC_start, SoC_A_cap, flex_up, flex_do, total_flex_up, total_flex_do, I, S, RM)


   #************************************************************************
   # Static Parameters
   T = 24 # hours on a day
   M = 60 # minutes in an hour
   M_d = T*M # minutes per model, i.e. per day
   Pen_e_coef = 6 # multiplier on energy for not delivering the activation -> 6, implies we have to pay the capacity back and that it 5 times as expensive tp buy the capacity back
   Pen_do = deepcopy(La_do)*Pen_e_coef  # intialize penalty cost
   Pen_up = deepcopy(La_up)*Pen_e_coef  # intialize penalty cost
   Pi = 1/S
   epsilon = 0.1                 # helper, so demominator won't become zero

   #************************************************************************
   # Model
   Mo  = Model(Gurobi.Optimizer)

   # varible per individual CB
   @variable(Mo, 0 <= Po[1:M_d, 1:I, s=1:S])        # Power delivered after activation - kW
   @variable(Mo, 0 <= Ma[1:M_d, 1:I, s=1:S])        # Max power - kW
   @variable(Mo, 0 <= SoC[1:M_d, 1:I, 1:S])         # Simulated Energy resovior level after activation - kWh
   @variable(Mo, 0 <= Ap_do_I[1:M_d, 1:I, 1:S])     # failed activation per CB per S
   @variable(Mo, 0 <= Ap_up_I[1:M_d, 1:I, 1:S])     # failed activation per CB per S
   @variable(Mo, 0 <= C_do_I[1:M_d, 1:I, 1:S])      # amount of downregulation distributed on CB on given scenario
   @variable(Mo, 0 <= C_up_I[1:M_d, 1:I, 1:S])      # amount of upregulation distributed on CB on given scenario
   @variable(Mo, 0 <= dis_do[1:M_d, 1:S])           # give us the minute wise distributions of bid flexibility
   @variable(Mo, 0 <= dis_up[1:M_d, 1:S])           # give us the minute wise distributions of bid flexibility
   @variable(Mo, 0 <= Ma_base[1:M_d, 1:I, 1:S])     # Max power baseline - kW
   @variable(Mo, 0 <= E_full[1:M_d, 1:I, 1:S])      # If bid for next 20 minutes where fulle activated how much energy would be charged
   @variable(Mo, 0 <= cap_mis_p[1:M_d, 1:I, 1:S])   # If bid for next 20 minutes where fulle activated many % of the energy would be missing on the resovior


   # Bid Varibles
   @variable(Mo, 0 <= C_up[1:M_d])                    # Chosen upwards bid
   @variable(Mo, 0 <= C_do[1:M_d])                    # Chosen downwards bid

   # pentalty Varibles
   @variable(Mo, 0 <= Ap_up[1:M_d, 1:S])              # Total failed upwards activation on minute basis
   @variable(Mo, 0 <= Ap_do[1:M_d, 1:S])              # Total failed downwards activation on minute basis
   @variable(Mo, 0 <= Ap_P_up[1:T, 1:S])              # The biggest total failed activation for a given we need to par for up
   @variable(Mo, 0 <= Ap_P_do[1:T, 1:S])              # The biggest total failed activation for a given  we need to par for down
   @variable(Mo, 0 <= per_dev_do[1:M_d, 1:S])         # The percentual over bid in respect to capacity for down bid
   @variable(Mo, 0 <= per_dev_up[1:M_d, 1:S])         # The percentual over bid in respect to capacity for up bid
   @variable(Mo, 0 <= kWh_left[1:M_d, 1:20, 1:I, 1:S])                      # amount of bid capacity not available
   @variable(Mo, 0 <= mi_cap_do)                      # amount of bid capacity not available

   # Objetives
   @variable(Mo, Income)                              # Total income on capacity
   @variable(Mo, 0 <= Penalty)                        # Total penalty based on missied activation

   ### Obejective ###
   @objective(Mo, Max,  Income-Penalty) ###

   # summerizing constraints
   @constraint(Mo, Income == sum( (C_up[(t-1)*60+1]*La_up[t,s] + C_do[(t-1)*60+1]*La_do[t,s])*Pi for t=1:T, s=1:S) ) ###
   @constraint(Mo, Penalty == sum(  (Ap_P_up[t,s]*Pen_up[t,s]+Ap_P_do[t,s]*Pen_do[t,s])*Pi for s=1:S, t=1:T) ) ###

   @constraint(Mo, Income-Penalty <= 1000000)

   ### Bid constraints ###
   # Aggregator Bid constraiants
   @constraint(Mo, [m=1:M_d, s=1:S], C_up[m] == sum(C_up_I[m,i,s] for i=1:I) )                                 # The upwards bid must be distributed over the charge boxses
   @constraint(Mo, [m=1:M_d, s=1:S], C_do[m] == sum(C_do_I[m,i,s] for i=1:I) )                                 # The downwards bid must be distributed over the charge boxses

   @constraint(Mo, [m=1:M_d, s=1:S], total_flex_up[m,s]*dis_up[m,s]  == sum(C_up_I[m,i,s] for i=1:I ) )                          # Help
   @constraint(Mo, [m=1:M_d, s=1:S], total_flex_do[m,s]*dis_do[m,s]  == sum(C_do_I[m,i,s] for i=1:I ) )                          # Help

   @constraint(Mo, [m=1:M_d, s=1:S, i=1:I], flex_up[m,i,s]*dis_up[m,s]  == C_up_I[m,i,s] )                                       # Help
   @constraint(Mo, [m=1:M_d, s=1:S, i=1:I], flex_do[m,i,s]*dis_do[m,s]  == C_do_I[m,i,s] )                                       # Help

   @constraint(Mo, [m=1:M_d, s=1:S], Ap_up[m,s] == sum(Ap_up_I[m,i,s] for i=1:I) )                             # The pentalty for not meeeting potential activation energy
   @constraint(Mo, [m=1:M_d, s=1:S], Ap_do[m,s] == sum(Ap_do_I[m,i,s] for i=1:I) )                             # The pentalty for not meeeting potential activation energy

   @constraint(Mo, [m=1:M, t=1:T, s=1:S], Ap_up[(t-1)*60+m,s] <= Ap_P_up[t,s] )                                  # Hourly activation penalty must be equal to minute where most energy is missed down
   @constraint(Mo, [m=1:M, t=1:T, s=1:S], Ap_do[(t-1)*60+m,s] <= Ap_P_do[t,s] )                                  # Hourly activation penalty must be equal to minute where most energy is missed up

   @constraint(Mo, [m=2:M, t=1:T], C_up[(t-1)*60+1] == C_up[(t-1)*60+m] )                                      # Bid must equal for all minutes in a hour
   @constraint(Mo, [m=2:M, t=1:T], C_do[(t-1)*60+1] == C_do[(t-1)*60+m] )                                      # Bid must equal for all minutes in a hour


   #### P90/bid available in 85% approximation constraints ###

   @constraint(Mo, [m=1:M_d, s=1:S], ( total_flex_up[m,s]-(C_up[m]+C_do[m]*0.2)+ epsilon)/( total_flex_up[m,s]+epsilon)+per_dev_up[m,s]  >= 0  )   # The Upwards flexibility has to be greater than the downwards bids plus to be 20% of the upwards bid, otherwise we'll have to enforce a capacity penalty
   @constraint(Mo, [m=1:M_d, s=1:S], ( (total_flex_do[m,s]+epsilon)-C_do[m])/(total_flex_do[m,s]+epsilon)+per_dev_do[m,s] >= 0    )                  # The downwards flexibility must be higher than the upwards bid, o.w, we don't have the capacity


   @constraint(Mo, sum( per_dev_up[m,s] for m=1:M_d, s=1:S)/(S*M_d) <= 0.01 )                                     # the average over overbid must be less than 10%
   @constraint(Mo, sum( per_dev_do[m,s] for m=1:M_d, s=1:S)/(S*M_d) <= 0.01 )                                     # the average over overbid must be less than 10%


   ### Operation constraints ###
   # energy related power constraint
<<<<<<< HEAD
   @constraint(Mo, [m=1:M_d, i=1:I, s=1:S], Po[m,i,s] == Power[m,i,s]-Ac_up[m,s]*(C_up_I[m,i,s]-Ap_up_I[m,i,s]) +Ac_do[m,s]*(C_do_I[m,i,s]-Ap_do_I[m,i,s]))   # The power is the baseline + the sum activation power
=======
   @constraint(Mo, [m=1:M_d, i=1:I, s=1:S], Po[m,i,s] == Power[m,i,s]-Ac_up[m,s]*(C_up_I[m,i,s]-Ap_up_I[m,i,s])
                                                                  +Ac_do[m,s]*(C_do_I[m,i,s]-Ap_do_I[m,i,s])  )   ### # The power is the baseline + the sum activation power
   @constraint(Mo, [m=1:M_d, i=1:I, s=1:S], Po[m,i,s] == Power[m,i,s]-Ac_up[m,s]*(C_up_I[m,i,s]-Ap_up_I[m,i,s]) +Ac_do[m,s]*(C_do_I[m,i,s]-Ap_do_I[m,i,s]+flex_do[m,i,s]*dis_do_after[m,s])  )   # The power is the baseline + the sum activation power
>>>>>>> 9acfc7c921639da96f407df4f77566b28316cbf0

   @constraint(Mo, [m=1:M_d, i=1:I, s=1:S], Po[m,i,s] <= Ma[m,i,s])                                               # The realized power must be smaller or equal to max power

   # Activation power constraint - these almost mimics the constraints above, however down and upwards activation within the same minute, can cancel out, and thus not mimic the actial flexibility needed to be delivered, hence the constraints below
   @constraint(Mo, [m=1:M_d, i=1:I, s=1:S], Ac_up[m,s]*(C_up_I[m,i,s]-Ap_up_I[m,i,s]) <= Power[m,i,s])            # The upwards regulation delivered must be smaller than the power had + the potential penalty
   @constraint(Mo, [m=1:M_d, i=1:I, s=1:S], Power[m,i,s]+Ac_do[m,s]*(C_do_I[m,i,s]-Ap_do_I[m,i,s]) <= Ma[m,i,s])              # The downwards regulation delivered must smaller than the max effect + the potential penalty


   # Max power constraint
   @constraint(Mo, [m=1:M_d, i=1:I, s=1:S], Ma[m,i,s] <= Power_rate[m,i,s]*Connected[m,i,s]  )                    # The charging power rate of the box must be higher than the Max power (Ma)
   for i=1:I
      for m=2:M_d
         for s=1:S
            if Connected[m,i,s] == 1 && Connected[m-1,i,s] != 0  # We need to look at m-1 for the resovior levels, as the power delivered at m, is what gives the SoC at the end
               @constraint(Mo, Ma[m,i,s] <= (kWh_cap[m-1,i,s]/po_cap[m-1,i,s]/RM-SoC[m-1,i,s] )*60  )             # The charging must not violaate the resovior max
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
"""
   for m=1:M_d
       m_a_max = m+19
       if m_a_max > M_d
         m_a_max = M_d
       end
       duration = (m_a_max+1-m)/60 # how long we have to sustain the activation, will 1/3 if we're lower than 1440
       for s=1:S
            for i=1:I
               for m1=m+1:m_a_max
                  if m1 == m_a_max && Connected[m1,i,s] == 1
                     @constraint(Mo, ( (kWh_cap[m1-1,i,s]/po_cap[m1-1,i,s]/RM - kWh_cap[m1-1,i,s]) - sum(C_up_I[m_2,i,s] for m_2=m:m1)/60 )/ (kWh_cap[m1-1,i,s]/po_cap[m1-1,i,s]/RM)  +kWh_left[m,m1-m,i,s]  >= 0 )        # get the kWh we missed for each minute
                     if m1 == 1
                        @constraint(Mo, ( (kWh_cap[m1,i,s]/po_cap[m1,i,s]/RM - SoC_start[i,s]) - sum(C_up_I[m_2,i,s] for m_2=m:m1)/60 )/ ( Wh_cap[m1,i,s]/po_cap[m1,i,s]/RM)  + kWh_left[m,m1-m,i,s] >= 0 )        # get the kWh we missed for each minute
                     end
                  elseif Connected[m1+1,i,s] == 0 && Connected[m1,i,s] == 1
                     @constraint(Mo, ( (kWh_cap[m1-1,i,s]/po_cap[m1-1,i,s]/RM - kWh_cap[m1-1,i,s]) - sum(C_up_I[m_2,i,s] for m_2=m:m1)/60 )/ (kWh_cap[m1-1,i,s]/po_cap[m1-1,i,s]/RM)  + kWh_left[m,m1-m,i,s]  >= 0 )        # get the kWh we missed for each minute
                     if m1 == 1
                        @constraint(Mo, ( (kWh_cap[m1,i,s]/po_cap[m1,i,s]/RM - SoC_start[i,s]) - sum(C_up_I[m_2,i,s] for m_2=m:m1)/60 )/ ( Wh_cap[m1,i,s]/po_cap[m1,i,s]/RM)  + kWh_left[m,m1-m,i,s]  >= 0 )        # get the kWh we missed for each minute
                     end
                  else
                     @constraint(Mo, kWh_left[m,m1-m,i,s] == 0)
                  end
               end
            end
       end
   end
"""
   #@constraint(Mo, per_dev_do[m,s] >= sum( sum(kWh_left[m,m1,i,s] for m1=1:20)  * sum( flex_do[m+m_a,i,s]/total_flex_do[m+m_a,s]  for m_a=m:m_a_max) for i=1:I)  )         # the overbid in upwards bid must be equal to at least the sverage charge box bid in avaible capacity in respect to full activation for 20 minutes


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

   return value.(C_up), value.(C_do), value.(C_up_I), value.(C_do_I), value.(Ap_up), value.(Ap_do), value(Penalty), value.(per_dev_up), value.(per_dev_do)
end
