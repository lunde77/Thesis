using Gurobi
using JuMP

#************************************************************************
# input parameters (varies per day):
#La_do                      # prices down for d-1 in h 24x1
#La_up                      # prices up for d-1 in h 24x1
#Ac_do                      # activation % downwards in m 1440x1
#Ac_up                      # activation % upwards in m 1440x1
#Power_rate                 # charging power rate of box in m 1440xI
#po_cap                     # % of resovior stored in m 1440xI
#kWh_cap                    # kWh of resovior charged in m 1440x1
#Power                      # baseline power in m 1440xI
#Connected                  # minutes where CB is connected in m 1440x1


# return (varies per day):
# value.(C_up_A)            # upwards bid for aggregator in kW in m 1440x1
# value.(C_do_A)            # downwards bid for aggregator in kW in m 1440x1
# value.(C_up)              # distributed of upwards bid in kW in m 1440xI
# value.(C_do)              # distributed of downwards bid in kW in m 1440xI
# value.(SoC[M_d,:])        # the expected Energy resovior in kWh at the end of the day 1xI
# value.(SoC_A)             # the expected Energy resovior in kWh for all minutes for the aggregated resovior
# value.(Ma_A)              # the expected Ma charging rate for the aggregator
# objective_value(Mo)       # The profit of bids

function Stocchastic_d1_model(La_do, La_up, Ac_do, Ac_up, Power_rate, po_cap, kWh_cap, Power, Connected, SoC_start, SoC_A_cap, I)

   #************************************************************************
   # Static Parameters
   T = 24 # hours on a day
   M = 60 # minutes in an hour
   M_d = T*M # minutes per model, i.e. per day
   S = 10
   RM = 1 # %-end SoC assumed

   #************************************************************************
   # Model
   Mo  = Model(Gurobi.Optimizer)

   # varible per individual CB
   @variable(Mo, 0 <= Po[1:M_d, 1:I])       # Power delivered after activation - kW
   @variable(Mo, 0 <= Ma[1:M_d, 1:I])       # Max power - kW
   @variable(Mo, 0 <= SoC[1:M_d, 1:I])      # Simulated Energy resovior level after activation - kWh
   @variable(Mo, 0 <= C_up[1:M_d, 1:I])     # Upwards bid placed on CB I - kW
   @variable(Mo, 0 <= C_do[1:M_d, 1:I])     # Downwards bid  on CB I  - kW

   # varible for aggregator
   @variable(Mo, 0 <= Po_A[1:M_d])          # aggregator Power delivered after activation - kW
   @variable(Mo, 0 <= Power_A[1:M_d])       # aggregator Power delivered before activation - kW
   @variable(Mo, 0 <= C_up_A[1:M_d])        # aggregator Upwards bid - kW
   @variable(Mo, 0 <= C_do_A[1:M_d])        # aggregator Downwards bid - kW
   @variable(Mo, 0 <= Ma_A[1:M_d])          # aggregator Max power - kW
   @variable(Mo, 0 <= SoC_A[1:M_d])         # aggregator SoC for two scenarios, s=1 no activation, s=2 for simulated activation


   # Obejective
   @objective(Mo, Max, sum( C_up_A[(t-1)*60+1]*La_up[t] + C_do_A[(t-1)*60+1]*La_do[t] for t=1:T) )

   # aggregator helper varibles
   @constraint(Mo, [m=1:M_d], Ma_A[m] == sum(Ma[m,i] for i=1:I) )                                         # The maximum charge is the sum of all max charging rates
   @constraint(Mo, [m=1:M_d], Po_A[m] == sum(Po[m,i] for i=1:I) )                                         # The power delivered for the aggregator is the sum of all
   @constraint(Mo, [m=1:M_d], Power_A[m] == sum(Power[m,i] for i=1:I) )                                   # The power delivered for the aggregator is the sum of all
   @constraint(Mo, [m=1:M_d], C_up_A[m] == sum(C_up[m,i] for i=1:I) )                                     # The upwards bid must be distributed over the charge boxses
   @constraint(Mo, [m=1:M_d], C_do_A[m] == sum(C_do[m,i] for i=1:I) )                                     # The downwards bid must be distributed over the charge boxses
   @constraint(Mo, [m=1:M_d], SoC_A[m,1] == sum(kWh_cap[m,i] for i=1:I))                                  # The aggregator SoC if no activation is realized

   # Aggregator Bid constraiants
   @constraint(Mo, [m=1:M_d], Ma_A[m]-Power_A[m] >= C_do_A[m] )                                           # The upwards flexibility has to be greater than the the the bids regulation
   @constraint(Mo, [m=1:M_d], Power_A[m] >= C_up_A[m]*0.2+C_do_A[m] )                                     # The downwards flexibility has to be greater than the the the bids regulation, hence there is delay factor added on
   @constraint(Mo, [m=1:M_d], (SoC_A_cap[m]-SoC_A[m,1]) >= C_do_A[m]*(1/3) )                              # There must at all times be enough resovior to be activated for 20 minutes of the - this is a

   # Flexibility constraint
   @constraint(Mo, [m=1:M_d, i=1:I], Ma[m,i]-Power[m,i] >= C_do[m,i] )                                    # The upwards flexibility has to be greater than the the the bids regulation
   @constraint(Mo, [m=1:M_d, i=1:I], Power[m,i] >= C_up[m,i] )                                            # The downwards flexibility has to be greater than the the the bids regulation

   # Max power constraint
   @constraint(Mo, [m=1:M_d, i=1:I], Ma[m,i] <= Power_rate[m,i]*Connected[m,i]  )                         # The charging power rate of the box must be higher than the Max power (Ma)
   for i=1:I
      for m=2:M_d
         if Connected[m,i] == 1 && Connected[m-1,i] != 0  # We need to look at m-1 for the resovior levels, as the power delivered at m, is what gives the SoC at the end
            @constraint(Mo, Ma[m,i] <= (kWh_cap[m-1,i]/po_cap[m-1,i]-SoC[m-1,i] )*60  )                   # The charging must not violaate the resovior max
         end
      end
   end

   # Power constraint
   @constraint(Mo, [m=1:M_d, i=1:I], Po[m,i] == Power[m,i]- Ac_up[m]*C_up[m,i]+Ac_do[m]*C_do[m,i])        # The power is the baseline + the activation power
   @constraint(Mo, [m=1:M_d, i=1:I], Po[m,i] <= Ma[m,i])                                                  # The realized power must be smaller or equal to max power
   for i=1:I
      for m=1:M_d
         if Connected[m,i] == 0
            @constraint(Mo, SoC[m,i] ==  0)                                                               # The SoC is to itepreted after the minutes, i.e. af after a non Connected minute, the SoC must be zero
         else
            if m ==  1
               @constraint(Mo, SoC[m,i] ==  SoC_start[i]+Po[m,i]/60)                                      # Update the SoC to have the power realized stored
               @constraint(Mo, SoC[m,i] <= kWh_cap[m,i]/po_cap[m,i]/RM )                                  # The SoC is not allowed to be greater or equal to the end SoC for chargin seesion
            else
               @constraint(Mo, SoC[m,i] ==  SoC[m-1,i]+Po[m,i]/60)                                        # Update the SoC to have the power realized stored
               @constraint(Mo, SoC[m,i] <= kWh_cap[m,i]/po_cap[m,i]/RM )                                  # The SoC is not allowed to be greater or equal to the end SoC for chargin seesion
            end
         end
      end
   end

   # Bid cosntraints
   @constraint(Mo, [m=1:M_d, i=1:I],  C_up[m,i] <= Connected[m,i]*M )                                     # Only bid when charger is Connected
   @constraint(Mo, [m=1:M_d, i=1:I],  C_do[m,i] <= Connected[m,i]*M )                                     # Only bid when charger is Connected

   @constraint(Mo, [m=2:M, t=1:T], C_up_A[(t-1)*60+1] == C_up_A[(t-1)*60+m] )                             # Bid must equal for all minutes in a hour
   @constraint(Mo, [m=2:M, t=1:T], C_do_A[(t-1)*60+1] == C_do_A[(t-1)*60+m] )                             # Bid must equal for all minutes in a hour


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

   return value.(C_up_A), value.(C_do_A), value.(C_up), value.(C_do), value.(Power_A), value.(Ma_A), value.(SoC_A), value.(SoC[M_d,:]), objective_value(Mo)
end
