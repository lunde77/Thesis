using Plots
using Statistics
using StatsPlots
using CSV
using DataFrames
using XLSX


##################

if true # plot flexibility of sample sapce vs bids

    # Sample data (replace this with your actual data)
    x = 1:1440  # Replace with your x-values

    # Sample bid values (replace this with your actual bid values)
    bid_values = ones(1440)*2 #Downwards_bids[:,2]  # Replace with your bid values
    S = 216
    total_flex_do_s_pl = zeros(1440,S)
    total_flex_up_s_5_pl = zeros(1440,S)
    total_flex_up_s_pl = zeros(1440,S)
    total_flex_e_s_pl = zeros(1440,S)

    for t=1:24
        for m=1:60
            total_flex_do_s_pl[(t-1)*60+m,:] = total_flex_do_s[t,m,:]
            total_flex_up_s_5_pl[(t-1)*60+m,:] = total_flex_up_s[t,m,:]*5
            total_flex_up_s_pl[(t-1)*60+m,:] = total_flex_up_s[t,m,:]
            total_flex_e_s_pl[(t-1)*60+m,:] = res_20_s[t,m,:]
        end
    end

    plot_sample_start = 1
    plot_sample_end = 1440

    q10_values = [quantile(total_flex_do_s_pl[i, :], 0.10) for i in 1:1440]
    q00_values = [findmin(total_flex_do_s_pl[i,:])[1] for i in 1:1440]
    q100_values = [findmax(total_flex_do_s_pl[i,:])[1] for i in 1:1440]

    lower_bound = bid_values[plot_sample_start:plot_sample_end] - q00_values[plot_sample_start:plot_sample_end]
    upper_bound = q100_values[plot_sample_start:plot_sample_end] - bid_values[plot_sample_start:plot_sample_end]



    plot(x[plot_sample_start:plot_sample_end],
         bid_values[plot_sample_start:plot_sample_end],
         ribbon = (-q00_values[plot_sample_start:plot_sample_end] + bid_values[plot_sample_start:plot_sample_end],
                   q100_values[plot_sample_start:plot_sample_end] - bid_values[plot_sample_start:plot_sample_end]),
         label = "",
         color = :orchid,
         fillalpha = 0.2,
         legend = :top,
         linecolor = :transparent, # Make the line transparent
         ylim = (0, 2000), # Set the limits for the y-axis here
         xguidefontsize = 13, # X-axis label font size
         yguidefontsize = 13, # Y-axis label font size
         xtickfontsize = 11, # X-axis tick font size
         ytickfontsize = 11, # Y-axis tick font size
         legendfontsize = 11,
         grid = false) # Legend font size

    plot!([NaN], [NaN], label="Sample set range", color = :orchid, fillalpha = 0.2)
    plot!(x[plot_sample_start:plot_sample_end], q10_values[plot_sample_start:plot_sample_end], line = :dash, color = :royalblue4, alpha = 0.3, label = "10th Quantile")

    xlabel!("Time (Minutes)")
    ylabel!("Downwards flexibility (kW)")
    title!("Dependent Sampling")
    savefig(raw"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Plots\sample space sampling 1 500 CBS new.png")

end

if false
    violation = zeros(25)

    down_1 = CSV.File(raw"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\CVaR VS ALSO-X downwards bids.csv") |> DataFrame #overbidder[:,:,1]
    down_1 = Matrix(down_1)

    up_1 = CSV.File(raw"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\CVaR VS ALSO-X Upwards  bids.csv") |> DataFrame #overbidder[:,:,1]
    up_1 = Matrix(up_1)

    bid_values_do = zeros(1440)
    bid_values_up = zeros(1440)
    for j=1:1440
        bid_values_do[j] = mean(down_1[j,1:5])
        bid_values_up[j] = mean(up_1[j,1:5])
    end

    total_flex_do_s_pl = zeros(1440,S)
    total_flex_up_s_5_pl = zeros(1440,S)
    total_flex_up_s_pl = zeros(1440,S)
    total_flex_e_s_pl = zeros(1440,S)

    for t=1:24
        for m=1:60
            total_flex_do_s_pl[(t-1)*60+m,:] = dis[1,:,t,m]
            total_flex_up_s_pl[(t-1)*60+m,:] = dis[2,:,t,m]
            total_flex_e_s_pl[(t-1)*60+m,:] = dis[3,:,t,m]
        end
    end

    #bid_values_do = Downwards_bids[:,1]
    #bid_values_up = Upwards_bids[:,1]

    for t=1:24
        for m=1:60
            for s=1:365
                if  total_flex_e_s_pl[(t-1)*60+m,s] < bid_values_do[(t-1)*60+m] || bid_values_do[(t-1)*60+m] > total_flex_do_s_pl[(t-1)*60+m,s]  || bid_values_do[(t-1)*60+m]*0.2 + bid_values_up[(t-1)*60+m] > total_flex_up_s_pl[(t-1)*60+m,s]
                    violation[t] = violation[t]+1
                end
            end
        end
        violation[t] = violation[t]/(M*365)*100
    end
    violation[25] = violation[24]

    print(violation)
    plot(0.5:24.5, violation, label="CVaR", linewidth=2, linestyle=:solid, linetype=:steppost, color=:green, legend=true)

    plot!(0.5:24.5, violation_ALSO, label="ALSO-X daily", linewidth=2, linestyle=:solid, linetype=:steppost, color=:red, legend=true)

    # Adding a horizontal line at y=10 with a label
    hline!([10], color=:blue, linestyle=:dash, linewidth=2, label="reference of ALSO-X hourly")


    xlabel!("Hour of day")
    ylabel!("% overbid for given hour")
    ylims!((0,25))
    title!("% overbid in IS")
    savefig(raw"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Plots\overbid_p vs bid.png")
end

if false

    bid_values = zeros(25)
    data = [randn(S*M) for _ in 1:24]
    for t=1:24
        for m=1:M
            for s=1:S
                data[t][(m-1)*S+s] = dis[2,s,t,m]*5
            end
        end
    end
    for t=1:24
        bid_values[t] = bid_values_do[(t-1)*60+1]
        bid_values_up[t] = bid_values_up[(t-1)*60+1]
    end
    bid_values[25] = bid_values[24]
    boxplot(data, legend=false)

    # Add bid values as a step line plot with a legend
    plot!(0.5:24.5, bid_values, label="Bid Values", linewidth=2, linestyle=:solid, linetype=:steppost, color=:red)


    xlabel!("Hour of day")
    ylabel!("kW")
    title!("Upwards flexibility * 5 Sample space")
    savefig(raw"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Plots\box plot vs bid.png")
end


######

if false  # plot distribution of overbids

    overbidder_1 = CSV.File(raw"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\CVaR overbidder_up daily models.csv") |> DataFrame #overbidder[:,:,1]
    overbidder_1 = Matrix(overbidder_1)

    overbidder_2 = CSV.File(raw"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\CVAR overbidder_do daily models.csv") |> DataFrame #overbidder[:,:,2]
    overbidder_2 = Matrix(overbidder_2)

    overbidder_3 = CSV.File(raw"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\CVaR overbidder_e daily models.csv") |> DataFrame #overbidder[:,:,3]
    overbidder_3 = Matrix(overbidder_3)

    # Flatten the 3D array into a 1D array
    flattened_matrix_1 = vec(overbidder_1)
    non_zero_elements_1 = filter(x -> x != 0, flattened_matrix_1)

    flattened_matrix_2 = vec(overbidder_2)
    non_zero_elements_2 = filter(x -> x != 0, flattened_matrix_2)

    flattened_matrix_3 = vec(overbidder_3)
    non_zero_elements_3 = filter(x -> x != 0, flattened_matrix_3)

    # Create a histogram of the non-zero elements
    using Plots

    bin_size = 0.2  # Set your desired bin size
    min_value = 0.0  # Set the minimum value
    max_value = 1.0  # Set the maximum value

    # Create a new figure with subplots, specifying the bin size and limits
    p1 = histogram(non_zero_elements_1.-0.2, nbins=Int((max_value - min_value) / bin_size), xlims=(min_value, max_value), legend=false, xlabel="% overbid req. 1")
    p2 = histogram(non_zero_elements_2.-0.2, nbins=Int((max_value - min_value) / bin_size), xlims=(min_value, max_value), legend=false, xlabel="% overbid req. 2")
    p3 = histogram(non_zero_elements_3.-0.2, nbins=Int((max_value - min_value) / bin_size), xlims=(min_value, max_value), legend=false, xlabel="% overbid req. 3")


    plot(p1, p2, p3, layout=(1, 3))

    savefig(raw"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Plots\overbid_distributtion_CVaR.png")

    total_missed = zeros(525600)
    for j=1:525600
        if flattened_matrix_1[j] >  flattened_matrix_2[j] &&  flattened_matrix_1[j] > flattened_matrix_3[j]
            total_missed[j] =  flattened_matrix_1[j]
        elseif flattened_matrix_2[j] > flattened_matrix_3[j]
            total_missed[j] =  flattened_matrix_2[j]
        else
            total_missed[j] =  flattened_matrix_3[j]
        end
    end
    non_zero_elements_all = filter(x -> x != 0, total_missed)

    histogram(non_zero_elements_all.-0.2, nbins=Int((max_value - min_value) / bin_size), xlims=(min_value, max_value), legend=false, xlabel="% of bid missing")

    savefig(raw"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Plots\overbid_distributtion_CVaR_overall.png")
end
