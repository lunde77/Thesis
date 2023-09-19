using Plots
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
    savefig("$base_path"*"4. Tests\\Plots\\Deterministic d1\\bids.png")


    plot(minutes, Po, label="Power", xlabel="Minutes", ylabel="Power", title="Power Comparison")
    plot!(minutes, Power, label="Original power")
    savefig("$base_path"*"4. Tests\\Plots\\Deterministic d1\\power.png")

    # Plot 3: SoC kWh_cap and realized SoC
    plot(minutes, kWh_cap, label="SoC baseline", xlabel="Minutes", ylabel="SoC", title="State of Charge (SoC) Comparison")
    plot!(minutes, SoC, label="Realized SoC")
    savefig("$base_path"*"4. Tests\\Plots\\Deterministic d1\\SoC.png")

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
    savefig("$base_path"*"4. Tests\\Plots\\Deterministic d1\\Aggregator bid.png")


    plot(minutes, A_power, label="Power", xlabel="Minutes", ylabel="kW", title="Power Comparison", linecolor=:yellow)
    plot!(minutes, A_Ma, label="Maximum power capacity", linecolor=:green)
    savefig("$base_path"*"4. Tests\\Plots\\Deterministic d1\\power vs capacity.png")

    # Plot 3: SoC kWh_cap and realized SoC
    plot(minutes, SoC, label="SoC of Aggregator resovior", xlabel="Minutes", ylabel="kWh", title="State of Charge (SoC) Comparison")
    plot!(minutes, A_Cap, label="Capacity of Aggregator resovior")
    savefig("$base_path"*"4. Tests\\Plots\\Deterministic d1\\SoC Aggregator.png")

end
