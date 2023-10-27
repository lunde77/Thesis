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

day = 40

plot(Do_bids_A[:,day], label="down bid")
plot!(Up_bids_A[:,day], label="up bid")
plot!(Total_flex_do[:,day], label="avg down flexibility")
plot!(Total_flex_up[:,day], label="avg up flexibility")
