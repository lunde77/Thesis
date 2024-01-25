using CSV
using DataFrames
using Random

global Emil = false

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"

end


# 1: revenue
# 2: penalty
# 3: down capacity missed - frequecy of overbid
# 4: up capacity missed - frequecy of overbid
# 5: energy capacity missed - frequecy of overbid
# 6: Total capacity missed - frequecy of overbid
# 7: avg. missed down capacity missed
# 8: avg. missed up capacity missed
# 9: avg. missed energy capacity missed
# 10: % down acatvation missed
# 11: % up acatvation missed
# 12: % of total upwards flexibity bid into the marked
# 13: % of total downwards flexibity bid into the marked
# 14: time taken for model to run
# 15: time taken to load all data

# 18: Upwards bid for each hour
# 18: downwards bid for each hour

global N_size = [1400, 700, 350, 200, 140, 100, 50, 20, 10]
global N_bundles   = [50, 100, 250, 500, 1400]

for x=1:4
    if x == 1
        CB_Is = collect(1:50)
    elseif x == 2
        CB_Is = collect(1:100)
    elseif x == 3
        CB_Is = collect(1:250)
    elseif x == 4
        CB_Is = collect(1:500)
    else
        CB_Is = collect(1:1400)
    end

    TE = 17
    NF = 3
    global results = zeros(TE,15)
    global magnitude_overbid = zeros(1440*365,TE)
    global Overbid_distribution = zeros(365,TE)
    global Upwards_bids = zeros(1440,TE*NF)
    global Downwards_bids = zeros(1440,TE*NF)
    global hourly_revenue = zeros(8760,TE)
    global hourly_penalty = zeros(8760,TE)

    for q=15:17
        if q <= 4
            q_in = (q-1)*0.5/100
        elseif q <=14
            q_in = (q-4)*2/100
        else
            q_in = ((q-14)*10+20)/100
        end

        global results[q,1], results[q,2], results[q,3:6], results[q,7:9], results[q,10:11], results[q,12], results[q,13], results[q,14], results[q,15], Overbid_distribution[:,q], Upwards_bids[:,(q-1)*NF+1:q*NF], Downwards_bids[:,(q-1)*NF+1:q*NF], xxx, magnitude_overbid[:,q], hourly_revenue[:,q], hourly_penalty[:,q] = Main_stochastic_CC_OSS_folded(CB_Is, "hourly", q_in)

        results_df = DataFrame(results, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\results_N_CBS_2_$(N_bundles[x]).csv", results_df)

        results_df = DataFrame(magnitude_overbid, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Magnituede_N_CBS_2_$(N_bundles[x]).csv", results_df)

        results_df = DataFrame(Overbid_distribution, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Overbid_distribution_N_CBS_2_$(N_bundles[x]).csv", results_df)

        results_df = DataFrame(Upwards_bids, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Upwards_bids_N_CBS_2_$(N_bundles[x]).csv", results_df)

        results_df = DataFrame(Downwards_bids, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Downwards_bids_N_CBS_2_$(N_bundles[x]).csv", results_df)

        results_df = DataFrame(hourly_penalty, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Hourly_penalty_N_2_CBS_$(N_bundles[x]).csv", results_df)

        results_df = DataFrame(hourly_revenue, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Hourly_revenue_N_CBS_2_$(N_bundles[x]).csv", results_df)

    end
end
