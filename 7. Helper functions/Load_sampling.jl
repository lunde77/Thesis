using Random
# input
# Day: what day are we sampling for -> not used, so just set to 1
# sampled_numbers: which days are IS, i.e. allowed to be used for sampling
# d_in: either "W" or "S", dertimning if it is a weekenday og weekday

# output:
# total_flex_do_s: downwards flexibity of samles
# total_flex_up_s: upwards flexibity of samles
# res_20_s: energyu flexibity of samles
function load_sampling_data(Day, sampled_numbers, d_in)

    ###### Initialize the samples for the given bid ######

    # Set the range and the number of samples
    num_samples = S

    total_flex_up_s = zeros(24, 60, num_samples)
    total_flex_do_s = zeros(24, 60, num_samples)
    res_20_s = zeros(24, 60, num_samples)

    if Sampling == 1  # radnom sampling from hourly distributions
        N = size(sampled_numbers)[1]

        global hourly_sample_minutes = zeros(60*N)
        for j=1:N
            for i=1:60
                hourly_sample_minutes[(j-1)*60+i] = ((sampled_numbers[j]-1)*60+i)
            end

        end
        hourly_sample_minutes = Int.(hourly_sample_minutes)
        for t=1:24
            for m=1:60
                hourly_sample_minutes = shuffle(hourly_sample_minutes)
                hourly_sample_minutes = shuffle(hourly_sample_minutes)
                global total_flex_do_s[t,m,:] = dis[1,hourly_sample_minutes[1:S],t]
                global total_flex_up_s[t,m,:] = dis[2,hourly_sample_minutes[1:S],t]
                global res_20_s[t,m,:] = dis[3,hourly_sample_minutes[1:S],t]
            end
        end

    elseif Sampling == 2 # Sampling from a minute-to-minute distribution, with non-dependtn sampling
        #Random.seed!(3) # set this to a number if we want to have same in sample and out sample across samples
        #shuffled_numbers = shuffle(sampled_numbers)
        for t=1:24
            for m=1:60
                shuffled_numbers = shuffle(sampled_numbers)
                total_flex_do_s[t,m,:] = dis[1,shuffled_numbers[1:S],t,m]
                total_flex_up_s[t,m,:] = dis[2,shuffled_numbers[1:S],t,m]
                res_20_s[t,m,:] = dis[3,shuffled_numbers[1:S],t,m]
            end
        end

    elseif Sampling == 3  # it is assmumed the K-folded OOS, with minut to minute correalted sampling, and we test based on which day we're on
        if d_in == "W"
            common_elements = intersect(sampled_numbers, D_w)
        elseif d_in == "S"
            common_elements = intersect(sampled_numbers, D_s)
        end
        sampled_days = Vector{Float64}()
        for j=1:size(sampled_numbers)[1]
            push!(sampled_days, Int16(rand(common_elements)))
        end

        for j=1:S
            for t=1:24
                for m=1:60
                    total_flex_do_s[t,m,j] = dis[1,Int16(sampled_days[j]),t,m]
                    total_flex_up_s[t,m,j] = dis[2,Int16(sampled_days[j]),t,m]
                    res_20_s[t,m,j] = dis[3,Int16(sampled_days[j]),t,m]
                end
            end
        end
    else  # if not sampling methods is sated, it is assmumed the K-folded OOS, with minut to minute correalted/time-sries sampling sampling
        #Random.seed!(3) # set this to a number if we want to have same in sample and out sample across samples
        shuffled_numbers = shuffle(sampled_numbers)
        for t=1:24
            for m=1:60
                total_flex_do_s[t,m,:] = dis[1,shuffled_numbers[1:S],t,m]
                total_flex_up_s[t,m,:] = dis[2,shuffled_numbers[1:S],t,m]
                res_20_s[t,m,:] = dis[3,shuffled_numbers[1:S],t,m]
            end
        end
    end

    return total_flex_do_s, total_flex_up_s, res_20_s
end
