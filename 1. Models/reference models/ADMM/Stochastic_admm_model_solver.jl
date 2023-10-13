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

function Stochastic_admm_solver(Mo, La_do, La_up, Ac_do, Ac_up, Power_rate, po_cap, kWh_cap, Power, Connected, SoC_start, SoC_A_cap, flex_up, flex_do, total_flex_up, total_flex_do, I, S, t, RM, gamma, lambda, up_input, do_input)


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
      I_o = 5
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
