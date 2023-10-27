using Plots
using Statistics


# Example 3D array
matrix = rand(0:1, 4, 4, 3)


# Flatten the 3D array into a 1D array
flattened_matrix_1 = vec(overbidder[:,:,1])
non_zero_elements_1 = filter(x -> x != 0, flattened_matrix_1)

flattened_matrix_2 = vec(overbidder[:,:,2])
non_zero_elements_2 = filter(x -> x != 0, flattened_matrix_2)

flattened_matrix_3 = vec(overbidder[:,:,3])
non_zero_elements_3 = filter(x -> x != 0, flattened_matrix_3)

# Create a histogram of the non-zero elements
using Plots



# Create a new figure with subplots
p1 = histogram(non_zero_elements_1, bins=10, legend=false, xlabel="Distribution 1")
p2 = histogram(non_zero_elements_2, bins=10, legend=false, xlabel="Distribution 2")
p3 = histogram(non_zero_elements_3, bins=10, legend=false, xlabel="Distribution 3")

plot(p1, p2, p3, layout=(1, 3))


##################

# Sample data (replace this with your actual data)
x = 1:1440  # Replace with your x-values
y = rand(1440, 162)  # Replace with your y-values

# Sample bid values (replace this with your actual bid values)
bid_values = Do_bids_A[:,11]  # Replace with your bid values

total_flex_do_s_pl = zeros(1440,S)

for t=1:24
    for m=1:60
        total_flex_do_s_pl[(t-1)*60+m,:] = total_flex_up_s[t,m,:]*5
    end
end

plot_sample_start = 1
plot_sample_end = 1440
# Calculate q10 and q90 values based on the first 7 values for each x
q10_values = [quantile(total_flex_do_s_pl[i, :], 0.00) for i in 1:1440]
q90_values = [quantile(total_flex_do_s_pl[i, :], 1.0) for i in 1:1440]
q50_values = [quantile(total_flex_do_s_pl[i, :], 0.5) for i in 1:1440]

# Create the envelope plot between q10 and q90 with labels
plot(x[plot_sample_start:plot_sample_end], bid_values[plot_sample_start:plot_sample_end], ribbon = (-q10_values[plot_sample_start:plot_sample_end]+bid_values[plot_sample_start:plot_sample_end], q90_values[plot_sample_start:plot_sample_end]-bid_values[plot_sample_start:plot_sample_end]), label = "10-90 quantile of smaples", fillalpha = 0.2, legend = true)

# Label the ribbon and the line components individually
plot!(x[plot_sample_start:plot_sample_end], bid_values[plot_sample_start:plot_sample_end], alpha = 1.0, label = "Bid")

xlabel!("Time (Minutes)")
ylabel!("Values")
title!("bids and samples for a given day (downwards)")
