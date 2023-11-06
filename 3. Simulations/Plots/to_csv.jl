

global to_csv = zeros(365,24*60)

for d=1:365
    for t=1:24
        for m=1:60
            global to_csv[d,(t-1)*60+m] = dis[1, d, t, m]
        end
    end
end

results_df = DataFrame(to_csv, :auto)
CSV.write("C:\\Users\\Gustav\\Documents\\Kandidat\\sampling.csv", results_df)
