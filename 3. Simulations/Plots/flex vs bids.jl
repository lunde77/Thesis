using Plots
using Statistics

##################

if true # plot flexibility of sample sapce vs bids

    # Sample data (replace this with your actual data)
    x = 1:1440  # Replace with your x-values
    y = rand(1440, 162)  # Replace with your y-values

    # Sample bid values (replace this with your actual bid values)
    bid_values = Do_bids_A[:,30]  # Replace with your bid values

    total_flex_do_s_pl = zeros(1440,S)

    for t=1:24
        for m=1:60
            total_flex_do_s_pl[(t-1)*60+m,:] = res_20_s[t,m,:]
        end
    end

    plot_sample_start = 1
    plot_sample_end = 1440-60

    q10_values = [quantile(total_flex_do_s_pl[i, :], 0.00) for i in 1:1440]
    q10_valuesT = [quantile(total_flex_do_s_pl[i, :], 0.10) for i in 1:1440]
    q90_values = [quantile(total_flex_do_s_pl[i, :], 1.0) for i in 1:1440]
    q50_values = [quantile(total_flex_do_s_pl[i, :], 0.5) for i in 1:1440]

    plot(x[plot_sample_start:plot_sample_end], bid_values[plot_sample_start:plot_sample_end], ribbon = (-q10_values[plot_sample_start:plot_sample_end]+bid_values[plot_sample_start:plot_sample_end], q90_values[plot_sample_start:plot_sample_end]-bid_values[plot_sample_start:plot_sample_end]), label = "Sample space (energy flexibility)", fillalpha = 0.2, legend = true)

    # Label the ribbon and the line components individually
    plot!(x[plot_sample_start:plot_sample_end], bid_values[plot_sample_start:plot_sample_end], alpha = 1.0, label = "Bid")
    plot!(x[plot_sample_start:plot_sample_end], q10_valuesT[plot_sample_start:plot_sample_end], line = :dash, color = :blue, alpha = 0.3, label = "10th Quantile")

    xlabel!("Time (Minutes)")
    ylabel!("Values")
    title!("bids and samples for a given day (downwards)")
    savefig(raw"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Plots\bids vs sample space.png")

end

######

if true  # plot distribution of overbids 

    # Flatten the 3D array into a 1D array
    flattened_matrix_1 = vec(overbidder[:,:,1])
    non_zero_elements_1 = filter(x -> x != 0, flattened_matrix_1)

    flattened_matrix_2 = vec(overbidder[:,:,2])
    non_zero_elements_2 = filter(x -> x != 0, flattened_matrix_2)

    flattened_matrix_3 = vec(overbidder[:,:,3])
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

    savefig(raw"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Plots\overbid_distributtion.png")

end
