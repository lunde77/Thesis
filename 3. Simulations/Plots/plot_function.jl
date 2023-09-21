using Plots
using CSV
using DataFrames
using Statistics
# C_up      # upwards bid (realized)
# C_do      # downwards bid (realized)
# Po        # power after activation
# power     # baseline power
# kWh_cap   # baseline SoC
# SoC       # SoC after activation

function plot_realized_data(C_up, C_do, Po, Power, kWh_cap, SoC)
    # Plot 2: Power after activation and original power
    minutes = 1:M_d
    # Plot 1: Realized bids for each hour
    plot(minutes, C_up, label="Upwards bids", xlabel="Hours", ylabel="kW", title="Bids for Each Hour")
    plot!(minutes, C_do, label="Downwards bids")
    savefig("$base_path"*"3. Simulations\\Plots\\Deterministic\\bids.png")


    plot(minutes, Po, label="Power", xlabel="Minutes", ylabel="Power", title="Power Comparison")
    plot!(minutes, Power, label="Original power")
    savefig("$base_path"*"3. Simulations\\Plots\\Deterministic\\power.png")

    # Plot 3: SoC kWh_cap and realized SoC
    plot(minutes, kWh_cap, label="SoC baseline", xlabel="Minutes", ylabel="SoC", title="State of Charge (SoC) Comparison")
    plot!(minutes, SoC, label="Realized SoC")
    savefig("$base_path"*"3. Simulations\\Plots\\Deterministic\\SoC.png")

end

# C_up_all  # upwards bid (realized)
# C_do_all  # downwards bid (realized)
# A_Ma      # Maximum power of system
# A_power   # Agreated power before activation
# A_Cap     # Aggregator resovior capacity
# SoC       # SoC

function plot_realized_data(C_up_all, C_do_all, A_Ma, A_power, A_Cap, SoC)
    # Plot 2: Power after activation and original power
    minutes = 1:M_d
    # Plot 1: Realized bids for each hour
    plot(minutes, C_up_all, label="Upwards bids", xlabel="Minutes", ylabel="kW", title="Bids for Each Hour", linecolor=:red)
    plot!(minutes, C_do_all, label="Downwards bids", linecolor=:blue)
    savefig("$base_path"*"3. Simulations\\Plots\\Deterministic\\Aggregator bid.png")


    plot(minutes, A_power, label="Power", xlabel="Minutes", ylabel="kW", title="Power Comparison", linecolor=:yellow)
    plot!(minutes, A_Ma, label="Maximum power capacity", linecolor=:green)
    savefig("$base_path"*"3. Simulations\\Plots\\Deterministic\\power vs capacity.png")

    # Plot 3: SoC kWh_cap and realized SoC
    plot(minutes, SoC, label="SoC of Aggregator resovior", xlabel="Minutes", ylabel="kWh", title="State of Charge (SoC) Comparison")
    plot!(minutes, A_Cap, label="Capacity of Aggregator resovior")
    savefig("$base_path"*"3. Simulations\\Plots\\Deterministic\\SoC Aggregator.png")

end

# filename_individuals : state how many individuals there are loaded, i.e. 1_50 mean all CB in that interval. Give as a string
# filename_aggregation: state how many Aggregator results there is loaded, i.e. 1_50_10 mean all CB in that interval are loaded with an intercal of 10. Give as a string
# Ag_interval: gives the interval that are Agreated upon
# CB_max: gives the last CB tested for
function synergy_plot(filename_individuals, filename_aggregation, Ag_interval, CB_max, Deterministic)


    intervals = zeros(Int(round(CB_max/Ag_interval)))

    for j=1:Int(round(CB_max/Ag_interval))
         intervals[j] = Ag_interval*j
    end

    if Emil
        base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
    else
        base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"
    end

    if Deterministic == true
        extra_path = "Deterministic results\\"
    else
        extra_path = "Stochastic results\\"
    end

    filepath = "$base_path"*"3. Simulations\\"*"$extra_path"*"aggregated_"*"$filename_aggregation.csv"
    df = CSV.File(filepath) |> DataFrame
    # Extracting the first column into a vector
    aggregation_pr = df[!, 1]


    filepath = "$base_path"*"3. Simulations\\"*"$extra_path"*"individual_"*"$filename_individuals.csv"
    df = CSV.File(filepath) |> DataFrame
    # Extracting the first column into a vector
    individuals_pr = df[!, 1]

    I = size(individuals_pr)[1]
    accumulated_p = zeros(I)
    synergy = zeros(Int(round(CB_max/Ag_interval)))
    global q = 1
    for i=1:I
        for j=1:i
            accumulated_p[i] = sum(individuals_pr[1:j])
            if j == intervals[q]
                synergy[q] = aggregation_pr[q]/accumulated_p[i]
                global q=q+1
            end
        end
    end

    x = pushfirst!(intervals, 0.0)
    y_values = pushfirst!(synergy, 1.0)  # Replace with your dataset

    window_size = 2
    y_rolling_mean = [mean(y_values[max(1, i-window_size+1):i]) for i in 2:length(y_values)]
    #y_rolling_mean = pushfirst!(y_rolling_mean, 1.0)  # Replace with your dataset

    plot(x, y_values, label="Synergy effect", marker=:circle, linewidth=2, line=(:line))
    #plot!(x, y_rolling_mean, label="Rolling Mean", marker=:square, linewidth=2, line=(:line, :dash), color=:red)


    ylabel!("Synergy effect")
    xlabel!("# of CBs'")
    savefig("$base_path"*"3. Simulations\\Plots\\Deterministic\\synergy effect.png")
end
