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

function Stochastic_admm(La_do, La_up, Ac_do, Ac_up, Power_rate, po_cap, kWh_cap, Power, Connected, SoC_start, SoC_A_cap, flex_up, flex_do, total_flex_up, total_flex_do, I, S, t, RM, gamma, lambda, up_input, do_input)


   #************************************************************************
   # Static Parameters
   M = 60 # minutes in an hour
   M_d = M*24 # minutes per model, i.e. per day
   Pen_e_coef = 6 # multiplier on energy for not delivering the activation -> 6, implies we have to pay the capacity back and that it 5 times as expensive tp buy the capacity back
   Pen_do = deepcopy(La_do)*Pen_e_coef  # intialize penalty cost
   Pen_up = deepcopy(La_up)*Pen_e_coef  # intialize penalty cost
   S = 10
   if I <= 0
      I_o = I
   else
      I_o = 0
   end
   Pi = 1/S
   epsilon = 0.1                 # helper, so demominator won't become zero

   ### parameters for limited CB ###
   flex_lim_CB_do_2 = sum(flex_do[:,1:I_o,:], dims=2)
   flex_lim_CB_up_2 = sum(flex_up[:,1:I_o,:], dims=2)

   flex_lim_CB_do = dropdims(flex_lim_CB_do_2, dims=2)
   flex_lim_CB_up = dropdims(flex_lim_CB_up_2, dims=2)

   for md=1:M_d
      for s=1:S
         flex_lim_CB_do[md,s] = flex_lim_CB_do[md,s] +0.0001
         flex_lim_CB_up[md,s] = flex_lim_CB_up[md,s] +0.0001
      end
   end

   ratio_flex_do = total_flex_do ./ (flex_lim_CB_do)
   ratio_flex_up = total_flex_up ./ (flex_lim_CB_up)

   ratio_flex_do = replace!(ratio_flex_do, NaN => 0.0)
   ratio_flex_up = replace!(ratio_flex_up, NaN => 0.0)

   df_ratio_do = Matrix{Float64}(undef, T, S)
   df_ratio_up = Matrix{Float64}(undef, T, S)

   for t=1:T
      for s=1:S
         df_ratio_do[t,s] = mean(ratio_flex_do[(1+60*(t-1)):(60*t),s])
         df_ratio_up[t,s] = mean(ratio_flex_up[(1+60*(t-1)):(60*t),s])
      end
   end


   # make quick fix to vettorize model

   fixer_cons_1 = zeros(M, I_o, S) # it the constrinat is fullfilled the fixer will take a one, meaning the max charge it not zero

   for i=1:I_o
      for m=2:M
         for s=1:S
            if Connected[(t-1)*60+m,i,s] == 1 && Connected[(t-1)*60+m-1,i,s] != 0  # We need to look at m-1 for the resovior levels, as the power delivered at m, is what gives the SoC at the end
               fixer_cons_1[m,i,s] = 1        # The charging must not violaate the resovior max
            end
         end
      end
   end

   global start = time_ns()
   #************************************************************************
   # Model
   Mo  = Model(Gurobi.Optimizer)

   # ADMM varibles
   @variable(Mo, 0 <= slack_up)                     # slack varible allowing for upwards bids
   @variable(Mo, 0 <= slack_do)                     # slack varible allowing for downwards bids

   # varible per individual CB
   @variable(Mo, 0 <= Po[1:M, 1:I_o, s=1:S])        # Power delivered after activation - kW
   @variable(Mo, 0 <= Ma[1:M, 1:I_o, s=1:S])        # Max power - kW
   @variable(Mo, 0 <= SoC[1:M, 1:I_o, 1:S])         # Simulated Energy resovior level after activation - kWh
   @variable(Mo, 0 <= Ap_do_I[1:M, 1:I_o, 1:S])     # failed activation per CB per S
   @variable(Mo, 0 <= Ap_up_I[1:M, 1:I_o, 1:S])     # failed activation per CB per S
   @variable(Mo, 0 <= C_do_I[1:M, 1:I, 1:S])      # amount of downregulation distributed on CB on given scenario
   @variable(Mo, 0 <= C_up_I[1:M, 1:I, 1:S])      # amount of upregulation distributed on CB on given scenario
   @variable(Mo, 0 <= dis_do[1:M, 1:S])           # give us the minute wise distributions of bid flexibility
   @variable(Mo, 0 <= dis_up[1:M, 1:S])           # give us the minute wise distributions of bid flexibility

   # Bid Varibles
   @variable(Mo, 0 <= C_up)                    # Chosen upwards bid
   @variable(Mo, 0 <= C_do)                    # Chosen downwards bid

   # pentalty Varibles
   @variable(Mo, 0 <= Ap_up[1:M_d, 1:S])              # Total failed upwards activation on minute basis
   @variable(Mo, 0 <= Ap_do[1:M_d, 1:S])              # Total failed downwards activation on minute basis
   @variable(Mo, 0 <= Ap_P_up[1:T, 1:S])              # The biggest total failed activation for a given we need to par for up
   @variable(Mo, 0 <= Ap_P_do[1:T, 1:S])              # The biggest total failed activation for a given  we need to par for down
   @variable(Mo, 0 <= per_dev_do[1:M, 1:S])         # The percentual over bid in respect to capacity for down bid
   @variable(Mo, 0 <= per_dev_up[1:M, 1:S])         # The percentual over bid in respect to capacity for up bid

   # Objetives
   @variable(Mo, Income)                              # Total income on capacity
   @variable(Mo, Penalty)                        # Total penalty based on missied activation

   ### Obejective ###
   @objective(Mo, Min,  -Income+lambda[1]*(sum(per_dev_up[m,s] for m=1:M, s=1:S)/(M_d*S))+lambda[2]*(sum(per_dev_do[m,s] for m=1:M, s=1:S )/(M_d*S) ) + (gamma[1])*( (sum(per_dev_up[m,s] for m=1:M, s=1:S)+up_input)/(M_d*S)-1+slack_up)^2+(gamma[2])*( (sum(per_dev_do[m,s] for m=1:M, s=1:S )+do_input)/(M_d*S)+slack_do-1)^2  )

   # summerizing constraints
   @constraint(Mo, Income == sum( (C_up*La_up[t,s] + C_do*La_do[t,s])*Pi for s=1:S) ) ###
   @constraint(Mo, Penalty == sum(  (Ap_P_up[t,s]*Pen_up[t,s]*df_ratio_up[t,s]+Ap_P_do[t,s]*Pen_do[t,s]*df_ratio_do[t,s])*Pi for s=1:S, t=1:T) ) ###

   ### Bid constraints ###
   # Aggregator Bid constraiants
   @constraint(Mo, [m=1:M, s=1:S], C_up == sum(C_up_I[m,i,s] for i=1:I) )                                      # The upwards bid must be distributed over the charge boxses
   @constraint(Mo, [m=1:M, s=1:S], C_do == sum(C_do_I[m,i,s] for i=1:I) )                                      # The downwards bid must be distributed over the charge boxses

   @constraint(Mo, [m=1:M, s=1:S, i=1:I], flex_up[(t-1)*60+m,i,s]*dis_up[m,s]  == C_up_I[m,i,s] )              # stating that the distributions must be equal on all chargevboxses
   @constraint(Mo, [m=1:M, s=1:S, i=1:I], flex_do[(t-1)*60+m,i,s]*dis_do[m,s]  == C_do_I[m,i,s] )              # stating that the distributions must be equal on all chargevboxses

   @constraint(Mo, [m=1:M, s=1:S], Ap_up[m,s] == sum(Ap_up_I[m,i,s] for i=1:I_o) )                             # The pentalty for not meeeting potential activation energy
   @constraint(Mo, [m=1:M, s=1:S], Ap_do[m,s] == sum(Ap_do_I[m,i,s] for i=1:I_o) )                             # The pentalty for not meeeting potential activation energy

   @constraint(Mo, [m=1:M, t=1:T, s=1:S], Ap_up[(t-1)*60+m,s] <= Ap_P_up[t,s] )                                # Hourly activation penalty must be equal to minute where most energy is missed down
   @constraint(Mo, [m=1:M, t=1:T, s=1:S], Ap_do[(t-1)*60+m,s] <= Ap_P_do[t,s] )                                # Hourly activation penalty must be equal to minute where most energy is missed up


   #### P90/bid available in 85% approximation constraints ###

   @constraint(Mo, [m=1:M, s=1:S], 100*( (total_flex_up[(t-1)*60+m,s]-(C_up+C_do*0.2)+ epsilon)/( total_flex_up[(t-1)*60+m,s]+epsilon) )+per_dev_up[m,s]  >= 0  )       # The Upwards flexibility has to be greater than the downwards bids plus to be 20% of the upwards bid, otherwise we'll have to enforce a capacity penalty
   @constraint(Mo, [m=1:M, s=1:S], 100*( ((total_flex_do[(t-1)*60+m,s]+epsilon)-C_do)/(total_flex_do[(t-1)*60+m,s]+epsilon))+per_dev_do[m,s] >= 0    )                  # The downwards flexibility must be higher than the upwards bid, o.w, we don't have the capacity

   ### Operation constraints ###
   # energy related power constraint

   @constraint(Mo, [m=1:M, i=1:I_o, s=1:S], Po[m,i,s] == Power[(t-1)*60+m,i,s]-Ac_up[(t-1)*60+m,s]*(C_up_I[m,i,s]-Ap_up_I[m,i,s]) +Ac_do[(t-1)*60+m,s]*(C_do_I[m,i,s]-Ap_do_I[m,i,s]))   # The power is the baseline + the sum activation power

   # Activation power constraint - these almost mimics the constraints above, however down and upwards activation within the same minute, can cancel out, and thus not mimic the actial flexibility needed to be delivered, hence the constraints below
   @constraint(Mo, [m=1:M, i=1:I_o, s=1:S], Ac_up[(t-1)*60+m,s]*(C_up_I[m,i,s]-Ap_up_I[m,i,s]) <= Power[(t-1)*60+m,i,s] )                        # The upwards regulation delivered must be smaller than the power had + the potential penalty
   @constraint(Mo, [m=1:M, i=1:I_o, s=1:S], Power[(t-1)*60+m,i,s]+Ac_do[(t-1)*60+m,s]*(C_do_I[m,i,s]-Ap_do_I[m,i,s]) <= Ma[m,i,s] )              # The downwards regulation delivered must smaller than the max effect + the potential penalty


   # Max power constraint
   @constraint(Mo, [m=1:M, i=1:I_o, s=1:S], Ma[m,i,s] <= Power_rate[(t-1)*60+m,i,s]*Connected[(t-1)*60+m,i,s]  )                    # The charging power rate of the box must be higher than the Max power (Ma)


   @constraint(Mo, [m=1:M, i=1:I_o, s=1:S], Ma[m,i,s] <= (kWh_cap[(t-1)*60+m-1,i,s]/(po_cap[(t-1)*60+m-1,i,s]+0.00001)/RM-SoC[m-1,i,s] )*60*fixer_cons_1[m,i,s] )


   @constraint(Mo, [m=1:M, i=1:I_o, s=1:S], SoC[m,i,s] <=  Connected[(t-1)*60+m,i,s]*25 )

   @constrinat(Mo, [i=I_o, s=1:S], SoC[1, i, s] ==  kWh_cap[(t-1)*60+m,i,s]/(po_cap[(t-1)*60+m,i,s]+0.00001)*Connected[(t-1)*60+m,i,s]+Po[m,i,s]/60 )  #### this has to be changed to SoC_start, as we're for now not reffering to the correct SoC, it should be m-1

   @constraint(Mo, [m=2:M, i=1:I_o, s=1:S], SoC[m,i,s] == (SoC[m-1,i,s]+Po[m,i,s]/60)*Connected[(t-1)*60+m,i,s] )

   @constraint(Mo, [m=2:M, i=1:I_o, s=1:S],  SoC[m,i,s] <= kWh_cap[(t-1)*60+m,i,s]/po_cap[(t-1)*60+m,i,s]/RM*Connected[(t-1)*60+m,i,s] )


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

   println(round((time_ns() - start) / 1e9, digits = 3))
   return value(C_up), value(C_do), value.(per_dev_up), value.(per_dev_do), value(slack_up), value(slack_do)
end
