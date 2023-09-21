# Day:              Day you want scenerios to be generated for
# Dataset:          kWh all data set


function scenario_generation_d1(Dataset, Day)


    scenario_matrix = []

    # The for loop + if statements sections creates the 10 scenarios an iteratively cat() (exept fot the first scenario) them to each other
    # Every new cat() gets a unique ID in the third dimension with maches its scenario number
    for j=(Day-11):(Day-2)

        if j < 1
            First_11_days = Dataset[end+1440*(j), :]
            New_matrix = First_11_days
        else
            Last_354_days = Dataset[1440*(j), :]
            New_matrix = Last_354_days
        end

        if j == (Day-11)
            scenario_matrix = New_matrix
        else
            scenario_matrix = cat(scenario_matrix, New_matrix, dims=2)
        end

    end

    return scenario_matrix

end
