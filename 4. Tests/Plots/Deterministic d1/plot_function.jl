
# C_up      # upwards bid (realized)
# C_do      # downwards bid (realized)
# Po        # power after activation
# power     # baseline power
# kWh_cap   # baseline SoC
# SoC       # SoC after activation

function plot_day(C_up, C_do, Po, Power, kWh_cap, SoC)
    # Plot 2: Power after activation and original power
    minutes = 1:M_d
    # Plot 1: Realized bids for each hour
    plot(minutes, C_up, label="Upwards bids", xlabel="Hours", ylabel="kW", title="Bids for Each Hour")
    plot!(minutes, C_do, label="Downwards bids")
    savefig("$base_path"*"4. Tests\\Plots\\Deterministic d1\\bids.png")


    plot(minutes, Po, label="Power after activation", xlabel="Minutes", ylabel="Power", title="Power Comparison")
    plot!(minutes, Power, label="Original power")
    savefig("$base_path"*"4. Tests\\Plots\\Deterministic d1\\power.png")

    # Plot 3: SoC kWh_cap and realized SoC
    plot(minutes, kWh_cap, label="SoC baseline", xlabel="Minutes", ylabel="SoC", title="State of Charge (SoC) Comparison")
    plot!(minutes, SoC, label="Realized SoC")
    savefig("$base_path"*"4. Tests\\Plots\\Deterministic d1\\SoC.png")

end
