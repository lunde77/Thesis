
function get_power(filtered_df)

    avg_resolution = 0
    n_resolution = 0.0
    max = 0

    # intialize parameteres
    POWER = zeros(M)
    m_b = 0 # minute of the observation before the minute of concern
    m_a = 0 # minute of the observation after the minute of concern
    i_b = 1 # itteration of the observation before the minute of concern
    i_a = 1 # itteration of the observation after the minute of concern
    e_a = 0 # energy of the observation after the minute of concern
    e_b = 0 # energy of the observation before the minute of concern
    m = 0

    while m < M

        m = m + 1
        # if itteration i_a is begger than the largest value in the dataframe, put m_a to m
        if i_a > size(filtered_df)[1]
            m_a = M
            e_a = 0
        else
            m_a = filtered_df.new_column[i_a]
        end
        while m_a < m
            i_a = i_a +1
            if i_a > size(filtered_df)[1]
                m_a = M
                e_a = 0
            else
                m_a = filtered_df.new_column[i_a]
                e_a = filtered_df.energy[i_a]
            end
        end


        i_b = i_a -1
        if i_b < 1
            m_b = 0
            e_b = 0
        else
            m_b = filtered_df.new_column[i_b]
            e_b = filtered_df.energy[i_b]
        end
        while m_b > m
            i_b = i_b -1
            m_b = filtered_df.new_column[i_b]
            e_b = filtered_df.energy[i_b]
        end

        # if energy after is smaller than energy before, then set power to 0
        if  (e_a-e_b)/(m_a-m_b)*60 < 0
            POWER[m] = 0
        else
            POWER[m] =  (e_a-e_b)/(m_a-m_b)*60
        end


        # hvis poweren er 0.5 og resolutionen er over 10 minutter
        if POWER[m] > 0.5 && (m_a-m_b) >= 10
            p = POWER[m] # set p the power found
            POWER[m] = 0
            i = 0
            while (p > 0) # and say while the power found was higher thnan zero, set it to zeros, to remove that carhge
                POWER[m-i] = 0
                i = i +1
                p = POWER[m-i] # set p the power found
            end

            while e_a > 0 # now we need to find the m, for when the charging period is over, i.e. when
                # energy rezovior is back to 0
                i_a = i_a +1
                if i_a > size(filtered_df)[1]
                    m_a = M
                    e_a = 0
                else
                    m_a = filtered_df.new_column[i_a]
                    e_a = filtered_df.energy[i_a]
                end


                m = floor.(Int, m_a)
            end

        end


        if POWER[m] > 0.5
            n_resolution = n_resolution + 1
            avg_resolution = avg_resolution+(m_a-m_b)
            if (m_a-m_b) >= max
                max = (m_a-m_b)
            end
        end


    end

    avg_resolution = avg_resolution/n_resolution
    println("The rnumber of res $n_resolution")
    println("The rnumber of res $n_resolution")
    println("The average resolution is $avg_resolution")
    println("with an maximum resolution of $max")

    return POWER, avg_resolution

end

# find the biggest charging power, thus find the charging capacidy
function find_charger(df_power)
    df_power = coalesce.(df_power, 0.0)
    max_charge = 0
    #typer = 3.7

    for t=1:size(df_power)[1]
        if max_charge < df_power[t]
            max_charge = df_power[t]
        end
    end

    #if 12.5 < max_charge
    #    typer = 22.08
    #elseif 8.5 < max_charge
    #    typer = 11.04
    #elseif 4 < max_charge
    #    typer = 7.36
    #end
    #println("the maximal output was $max_charge")

    max_vector = zeros(M)
    for m=1:M
        max_vector[m] = max_charge
    end

    return max_vector
end


function filter_power(power_vector, max_power)

    for m=1:M
        if power_vector[m] > 0
            if power_vector[m-1] <= 0  && power_vector[m+1] <= 0
                power_vector[m] = 0
            end
        end
        if power_vector[m] > max_power
             power_vector[m] = max_power
        end
    end

    return power_vector
end


function get_resovior(power_vector)

    resovior = zeros(M)
    m = 0
    while m+1 <= M
        m = m +1
        end_j = M
        if power_vector[m] > 0
            for j=m:M
                if power_vector[j] == 0
                    end_j = j
                    break
                end
            end

            E_end = sum(power_vector[m:end_j-1])/60

            for i=m:end_j-1
                resovior[i] = (sum(power_vector[m:i])/60)/E_end
            end

            m = end_j-1
            end_j = 0

        end

    end

    return resovior
end

function get_connected(resovior_vector)

    connected = zeros(M)
    for m=1:M
        if resovior_vector[m] > 0.0
            connected[m] = 1
        end
    end

    return connected
end

function get_minutes()
    minutes = zeros(24*60*365)
    for m=1:(24*60*365)
        minutes[m] = Int64(m)
    end

    return minutes
end

function get_SoC(connected, power, SoC_p)
    SoC = zeros(24*60*365)

    m = 0
    while m < M
        m = m + 1 # increment minutes
        co = connected[m] # get if charger is connected
        energy_end = 0 # state tha the energy at the end is zero before charging start
        while co == 1
            energy_end = energy_end + power[m]/60 # updatet energy
            m = m +1 # increment minutes
            co = connected[m] # see if charger is conncted
            if co == 0 # if not, it means that session has ended
                i = 1 # now backstrack
                co_2 = connected[m-i]
                while co_2 == 1 # as long as charger was connected
                    SoC[m-i] = energy_end*SoC_p[m-i] # find the kWh charged at that point, by fraction of total chared
                    i = i+1 # increment
                    co_2 = connected[m-i] # see if it was connedted
                end
            end
        end


    end

    return SoC
end



function make_data(target_cbid)

    global M =  24*60*365

    EV_DATA = zeros(1, M, 6) #  energy_resovior-%, power, connected,  max_effect of charger,  m of year

    # Filter rows based on the CBID column
    filtered_df = df[df.CBID .== target_cbid, :]

    # Define the reference timestamp "23/3/2022 00:00:00"
    reference_timestamp_str = "23/3/2022 00:00:00"
    reference_timestamp = Dates.DateTime(reference_timestamp_str, "d/m/y H:M:S")

    # Function to calculate minutes since the reference timestamp
    function minutes_since_reference(timestamp_str)
        timestamp = Dates.DateTime(timestamp_str, "d/m/y H:M:S")
        time_difference = timestamp - reference_timestamp
        minutes_since = Dates.value(Dates.Millisecond(time_difference))*1.66666667* 10^(-5)
        return minutes_since
    end

    # Apply the function to the "timestamp" column and create a new column "minutes_since_reference"
    time_since = zeros(size(filtered_df)[1])
    for i=1:size(filtered_df)[1]
        global time_since[i] = minutes_since_reference(filtered_df[i,7])
    end


    filtered_df.new_column = time_since


    # is the latest data pint was no recorded after day 300 of the year, we assume that the data is now full
    if time_since[size(filtered_df)[1]] <= 60*24*300
        println("dataset $target_cbid was not full")
        return EV_DATA[1,:,:], false, 10
    end

    # if has run out of memory
    if size(EV_DATA)[2] <= 425600
        println("out of memory")
        println("out of memory")
        return EV_DATA[1,:,:], true, 10
    end


    EV_DATA[1, :, 3], avg_resolution =  get_power(filtered_df)
    EV_DATA[1, :, 5] =  find_charger(filtered_df.power)
    # if has run out of memory
    if EV_DATA[1, 1, 3] >= 22.2
        println("the mac charge was to high")
        println("the mac charge was to high")
        return EV_DATA[1,:,:], true, avg_resolution
    end
    EV_DATA[1, :, 3] =  filter_power(EV_DATA[1, :, 3], EV_DATA[1, 1, 5])
    EV_DATA[1, :, 1] =  get_resovior(EV_DATA[1, :, 3])
    EV_DATA[1, :, 4] =  get_connected(EV_DATA[1, :, 1])
    EV_DATA[1, :, 6] =  get_minutes()
    EV_DATA[1, :, 2] =  get_SoC( EV_DATA[1, :, 4] ,     EV_DATA[1, :, 3],     EV_DATA[1, :, 1])
#    plot(EV_DATA[1,:,2], label  = "Power")
#    plot!(EV_DATA[1,:,1], label = "resovior")
#    plot!(EV_DATA[1,:,3], label = "conncted")
#    plot!(EV_DATA[1,:,4], label = "Max charger power")

    return EV_DATA[1,:,:], true, avg_resolution
end
