# Day:              Day you want scenerios to be generated for
# Dataset:          The parameters you want scenarios to be generated for 


function scenario_generation_m(Dataset, Day)


    scenario_matrix = []

    # The for loop + if statements sections creates the 10 scenarios an iteratively cat() (exept fot the first scenario) them to each other
    # Every new cat() gets a unique ID in the third dimension with maches its scenario number
    for j=Day:(Day+9)

        if j <= 11
            First_11_days = Dataset[end-1440*(12-j)+1:end-1440*(11-j), :]
            New_matrix = First_11_days
        else
            Last_354_days = Dataset[1440*(j-12)+1:1440*(j-11), :]
            New_matrix = Last_354_days
        end

        if j == Day
            scenario_matrix = New_matrix
        else
            scenario_matrix = cat(scenario_matrix, New_matrix, dims=3)
        end

    end

    return scenario_matrix

end
