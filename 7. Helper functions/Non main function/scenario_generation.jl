# Day:              Day you want scenerios to be generated for
# Dataset:          The parameters you want scenarios to be generated for

# The scenarios are generated such that first scenario is, i.e. s=1, is the one furthest away from the day of concern
# scenario S is two days removed from the day of concern
function scenario_generation_m(Dataset, Day, dim)


    scenario_matrix = []

    # Check if Dataset is 1 or 2 dimensional
    if dim == 1
        # The for loop + if statements sections creates the 10 scenarios an iteratively cat() (exept fot the first scenario) them to each other
        # Every new cat() gets a unique ID in the third dimension with maches its scenario number
        if  size(Dataset)[1] > 24*365
            for j=Day:(Day+9)

                if j <= 11
                    First_11_days = Dataset[end-1440*(12-j)+1:end-1440*(11-j)]
                    New_matrix = First_11_days
                else
                    Last_354_days = Dataset[1440*(j-12)+1:1440*(j-11)]
                    New_matrix = Last_354_days
                end

                if j == Day
                    scenario_matrix = New_matrix
                else
                    scenario_matrix = cat(scenario_matrix, New_matrix, dims=2)
                end

            end
        else
            # The for loop + if statements sections creates the 10 scenarios an iteratively cat() (exept fot the first scenario) them to each other
            # Every new cat() gets a unique ID in the third dimension with maches its scenario number

            scenario_matrix = zeros(T,S)
            for j=Day:(Day+9)

                if j <= 11
                    scenario_matrix[:,j-Day+1] = Dataset[end-24*(12-j)+1:end-24*(11-j), :]
                else
                    scenario_matrix[:,j-Day+1]  = Dataset[24*(j-12)+1:24*(j-11), :]
                end

            end
        end

    elseif dim == 2
        scenario_matrix = zeros(M_d,I,S)
        # The for loop + if statements sections creates the 10 scenarios an iteratively cat() (exept fot the first scenario) them to each other
        # Every new cat() gets a unique ID in the third dimension with maches its scenario number
        for j=Day:(Day+9)

            if j <= 11
                scenario_matrix[:,:,-Day+1+j] = Dataset[end-1440*(12-j)+1:end-1440*(11-j), :]
                #New_matrix = First_11_days

            else
                scenario_matrix[:,:,-Day+1+j] = Dataset[1440*(j-12)+1:1440*(j-11), :]
                #New_matrix = Last_354_days
            end

            #if j == Day
            #    scenario_matrix = New_matrix
            #else
            #    scenario_matrix = cat(scenario_matrix, New_matrix, dims=3)
            #end

        end

    else
        nothing
    end

    return scenario_matrix

end
