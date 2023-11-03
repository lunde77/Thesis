using CSV
using DataFrames
using Plots

Emil = false
Deterministic = false

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



filepath = raw"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\10-10_10.csv"
df = CSV.File(filepath) |> DataFrame
# Extracting the first column into a vector
down_1 = df[!, 8]
up_1 = df[!, 7]
rev1 = df[!, 1]

filepath = raw"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\150-500_50.csv"
df_2 = CSV.File(filepath) |> DataFrame
# Extracting the first column into a vector
down_2 = df_2[!, 8]
up_2 = df_2[!, 7]
rev_2 = df_2[!, 1]


y = vcat(down_1,down_2)
y2 = vcat(up_1,up_2)
y_rev = vcat(rev1,rev_2)


x = [10,20,30,40,50,60,70,80,90,100,150,200,250,300,350,400,450,500]


# Simple plot
plot(x, y*100, label="Downwards", title="Synergy Effect of Aggregation", xlabel="n. of charge boxses in portfolio", ylabel="% of total portfolio flexbility bid into market", linewidth=2)

# If you have a second y (e.g., y2), you can add it like:
plot!(x, y2*100, label="Upwards", linewidth=2, linestyle=:dash, color=:red)


savefig("$base_path"*"3. Simulations\\Plots\\Stochastic\\synergy effect capacity.png")

# Simple plot
plot(x, y_rev, title="Synergy Effect of Aggregation", xlabel="n. of charge boxses in portfolio", ylabel="Revenue (DKK)", linewidth=2)


savefig("$base_path"*"3. Simulations\\Plots\\Stochastic\\Rev.png")
