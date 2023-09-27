function scenario_90_reservoir(po_cap_s, kWh_cap_s)

    ### The input dataset will have the dimension M_dxIxS where M_d is the minutes per day, I is amount of CBs and S is the amount of scenarios
    # M_d is always 1440
    # I is always unknown
    # S is always userdefined

    # calculating the reservoir
    Scenario_dataset = (kWh_cap_s/po_cap_s - kWh_cap_s/RM)*60 

    # summing over the second dimension (1:I) to get the aggregated sum 
    aggregated_Scenario_dataset = sum(Scenario_dataset, dims=2)
    # dropping the scond dimension
    Scenario_dataset_2D = dropdims(aggregated_Scenario_dataset, dims=2)
    # we now have a [1:1440,1:userdefined] dimensioned matrix

    ### now the 90p "worst" scenario is found and thereafter stored in second_worst_scenarios
    worst_scenarios_90p = []

    for md in 1:M_d
        # Sort the scenarios in the md-th set
        sorted_indices = sortperm(Scenario_dataset_2D[md, :])
        
        # The index of the 90p "worst" scenario in the md-th set is the (S*(1-0.9)) element in sorted_indices where the worst scenario = the lowest valued element
        second_worst_index = sorted_indices[(S*(1-0.9))]  
        
        # Store the index and outcome of the second-worst scenario
        push!(second_worst_scenarios, Scenario_dataset_2D[md, second_worst_index])
    end

    return second_worst_scenarios

end

