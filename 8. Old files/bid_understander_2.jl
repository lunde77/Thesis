global up_bid = zeros(24, day_end)
global do_bid =  zeros(24, day_end)

global flex_do = zeros(24, day_end)
global flex_up =  zeros(24, day_end)
for d=1:day_end
   for t=1:24

        up_bid[t,d] = Up_bids_A[t*60,d]
        do_bid[t,d] = Do_bids_A[t*60,d]

        flex_do[t,d] = sum(Total_flex_do[(t-1)*60+1:t*60,d])/60
        flex_up[t,d] = sum(Total_flex_up[(t-1)*60+1:t*60,d])/60

    end
    println(sum(flex_up[:,d]))
    println(sum(do_bid[:,d]))
    println()
end

day = 3

plot(Do_bids_A[:,day], label="down bid")
plot!(Up_bids_A[:,day], label="up bid")
plot!(Total_flex_do[:,day], label="avg down flexibility")
plot!(Total_flex_up[:,day], label="avg up flexibility")


plot(total_flex_up_s[:,1])
plot!(total_flex_up_s[:,2])
plot!(total_flex_up_s[:,3])
plot!(total_flex_up_s[:,4])
plot!(total_flex_up_s[:,5])
plot!(total_flex_up_s[:,6])
plot!(total_flex_up_s[:,7])
plot!(total_flex_up_s[:,8])
plot!(total_flex_up_s[:,9])
plot!(total_flex_up_s[:,10])


plot(total_flex_do_s[:,1])
plot!(total_flex_do_s[:,2])
plot!(total_flex_do_s[:,3])
plot!(total_flex_do_s[:,4])
plot!(total_flex_do_s[:,5])
plot!(total_flex_do_s[:,6])
plot!(total_flex_do_s[:,7])
plot!(total_flex_do_s[:,8])
plot!(total_flex_do_s[:,9])
plot!(total_flex_do_s[:,10])


plot(res_20_s[1:1339,1])
plot!(res_20_s[1:1339,2])
plot!(res_20_s[1:1339,3])
plot!(res_20_s[1:1339,4])
plot!(res_20_s[1:1339,5])
plot!(res_20_s[1:1339,6])
plot!(res_20_s[1:1339,7])
plot!(res_20_s[1:1339,8])
plot!(res_20_s[1:1339,9])
plot!(res_20_s[1:1339,10])
