using DataFrames
using XLSX
using CSV



dis = zeros(3,21900,24)
for d=1:365
    for t=1:24
        for m=1:M
            dis[1,(d-1)*60+m,t] = float(sum( Downwards_flex_all[(d-1)*1440+(t-1)*60+m,:] ))
            dis[2,(d-1)*60+m,t] = float(sum( Upwards_flex_all[(d-1)*1440+(t-1)*60+m,:] ))
            dis[3,(d-1)*60+m,t] = float(sum( energy_20_all[(d-1)*1440+(t-1)*60+m,:] )*60)
        end
    end
end





#for j=1:24
#    data[:,j] = p[j]
#end

# Convert the vector of vectors to a DataFrame
df = DataFrame(dis[1,:,:], :auto)

# Specify the output file path
output_file = raw"C:\Users\Gustav\Documents\Kandidat\tester_do.csv"
CSV.write(output_file, df)

df = DataFrame(dis[2,:,:], :auto)
output_file = raw"C:\Users\Gustav\Documents\Kandidat\tester_up.csv"
CSV.write(output_file, df)

df = DataFrame(dis[3,:,:], :auto)
output_file = raw"C:\Users\Gustav\Documents\Kandidat\tester_E.csv"
CSV.write(output_file, df)

histogram(dis[2,:,1], legend=false, title="Data Distribution", xlabel="Value", ylabel="Frequency")
