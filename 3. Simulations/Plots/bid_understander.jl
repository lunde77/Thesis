global up_bid = zeros(24, day_end)
global do_bid =  zeros(24, day_end)

global flex_do = zeros(24, day_end)
global flex_up =  zeros(24, day_end)
for d=1:day_end
   for t=1:24

        up_bid[t,d] = Up_bids_A[t*60,d]
        do_bid[t,d] = Do_bids_A[t*60,d]

        flex_do[t,d] = Total_flex_do[t*60,d]
        flex_up[t,d] = Total_flex_up[t*60,d]

    end
    println(sum(flex_up[:,d]))
    println(sum(do_bid[:,d]))
    println()
end

day = 6

plot(do_bid[:,day])
plot!(up_bid[:,day])
plot!(flex_do[:,day])
plot!(flex_up[:,day])
