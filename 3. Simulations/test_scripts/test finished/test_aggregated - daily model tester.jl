using CSV
using DataFrames
using Random

global Emil = false

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"

end

TE = 18

results = zeros(TE,15)
Overbid_distribution = zeros(365,TE)
Upwards_bids = zeros(1440,TE*365)
Downwards_bids = zeros(1440,TE*365)

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



for i=1:0
    CB_Is = collect(1:500)
    q = 1
    global results[q,1], results[q,2], results[q,3:6], results[q,7:9], results[q,10:11], results[q,12], results[q,13], results[q,14], results[q,15], overbidder_also_daily, Overbid_distribution[:,q], Upwards_bids[:,(q-1)*5+1:q*5], Downwards_bids[:,(q-1)*5+1:q*5] = Main_stochastic_CC_OSS_folded(CB_Is, "daily")
    q = 2
    global results[q,1], results[q,2], results[q,3:6], results[q,7:9], results[q,10:11], results[q,12], results[q,13], results[q,14], results[q,15], overbidder_also_hourly, Overbid_distribution[:,q], Upwards_bids[:,(q-1)*5+1:q*5], Downwards_bids[:,(q-1)*5+1:q*5] = Main_stochastic_CC_OSS_folded(CB_Is, "hourly")
    q = 3
    global results[q,1], results[q,2], results[q,3:6], results[q,7:9], results[q,10:11], results[q,12], results[q,13], results[q,14], results[q,15], overbidder_CVAR_daily, Overbid_distribution[:,q], Upwards_bids[:,(q-1)*5+1:q*5], Downwards_bids[:,(q-1)*5+1:q*5] =  Main_stochastic_CVAR_OSS_folded(CB_Is, "daily")
    q = 4
    global results[q,1], results[q,2], results[q,3:6], results[q,7:9], results[q,10:11], results[q,12], results[q,13], results[q,14], results[q,15], overbidder_CVAR_hourly, Overbid_distribution[:,q], Upwards_bids[:,(q-1)*5+1:q*5], Downwards_bids[:,(q-1)*5+1:q*5] =  Main_stochastic_CVAR_OSS_folded(CB_Is, "daily")

    results_df = DataFrame(results, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\CVaR VS ALSO-X daily models generel results.csv", results_df)

    results_df = DataFrame(Overbid_distribution, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\CVaR VS ALSO-X daily models overbid_distribution.csv", results_df)

    results_df = DataFrame(overbidder_also_daily[:,:,1], :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\ALSO overbidder_up daily models.csv", results_df)

    results_df = DataFrame(overbidder_also_daily[:,:,2], :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\ALSO overbidder_do daily models.csv", results_df)

    results_df = DataFrame(overbidder_also_daily[:,:,3], :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\ALSO overbidder_e daily models.csv", results_df)

    results_df = DataFrame(overbidder_CVAR_daily[:,:,1], :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\CVAR overbidder_up daily models.csv", results_df)

    results_df = DataFrame(overbidder_CVAR_daily[:,:,2], :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\CVAR overbidder_do daily models.csv", results_df)

    results_df = DataFrame(overbidder_CVAR_daily[:,:,3], :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\CVAR overbidder_e daily models.csv", results_df)

    results_df = DataFrame(overbidder_also_hourly[:,:,1], :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\ALSO overbidder_up hourly models.csv", results_df)

    results_df = DataFrame(overbidder_also_hourly[:,:,2], :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\ALSO overbidder_do hourly models.csv", results_df)

    results_df = DataFrame(overbidder_also_hourly[:,:,3], :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\ALSO overbidder_e hourly models.csv", results_df)

    results_df = DataFrame(overbidder_CVAR_hourly[:,:,1], :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\CVAR overbidder_up hourly models.csv", results_df)

    results_df = DataFrame(overbidder_CVAR_hourly[:,:,2], :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\CVAR overbidder_do hourly models.csv", results_df)

    results_df = DataFrame(overbidder_CVAR_hourly[:,:,3], :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\CVAR overbidder_e daily models.csv", results_df)
end



for i=1:1
    CB_Is = collect(1:500)
    #q = 1
    #global results[q,1], results[q,2], results[q,3:6], results[q,7:9], results[q,10:11], results[q,12], results[q,13], results[q,14], results[q,15], overbidder_also_daily, Overbid_distribution[:,q], Upwards_bids[:,(q-1)*5+1:q*5], Downwards_bids[:,(q-1)*5+1:q*5] = Main_stochastic_CC_OSS_folded(CB_Is, "daily")
    #q = 2
    #global results[q,1], results[q,2], results[q,3:6], results[q,7:9], results[q,10:11], results[q,12], results[q,13], results[q,14], results[q,15], overbidder_also_hourly, Overbid_distribution[:,q], Upwards_bids[:,(q-1)*5+1:q*5], Downwards_bids[:,(q-1)*5+1:q*5] = Main_stochastic_CC_OSS_folded(CB_Is, "hourly")
    #q = 3
    #global results[q,1], results[q,2], results[q,3:6], results[q,7:9], results[q,10:11], results[q,12], results[q,13], results[q,14], results[q,15], overbidder_CVAR_daily, Overbid_distribution[:,q], Upwards_bids[:,(q-1)*5+1:q*5], Downwards_bids[:,(q-1)*5+1:q*5] =  Main_stochastic_CVAR_OSS_folded(CB_Is, "daily")
    q = 4
    global results[q,1], results[q,2], results[q,3:6], results[q,7:9], results[q,10:11], results[q,12], results[q,13], results[q,14], results[q,15], overbidder_also_minute, Overbid_distribution[:,q], Upwards_bids[:,(q-1)*10+1:q*10], Downwards_bids[:,(q-1)*10+1:q*10] =  Main_stochastic_CC_OSS_folded(CB_Is, "hourly")




    results_df = DataFrame(results, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\ALSO conditional distributio.csv", results_df)

    results_df = DataFrame(Overbid_distribution, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\conditional distributio. overbid_distribution_new.csv", results_df)

    results_df = DataFrame(overbidder_also_minute[:,:,1], :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\conditional distributio. overbidder_do hourly models_new.csv", results_df)

    results_df = DataFrame(overbidder_also_minute[:,:,2], :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\conditional distributio. overbidder_up hourly models_new.csv", results_df)

    results_df = DataFrame(overbidder_also_minute[:,:,3], :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\conditional distributio. overbidder_e hourly models_new.csv", results_df)

end
