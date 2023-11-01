using CSV
using DataFrames

global Emil = false

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"

end

results = zeros(2,8)

# 1: objetive
# 2: missed actation
# 3: down capacity missed
# 4: up capacity missed
# 5: down labmda change at last itteration
# 6: up lambda change at last itteration
# 7: itteation in last bid shcudle creation
# 8: time taken

for i=1:2
    CB_Is = collect(1:i*50)
    if i == 1
        CB_Is = collect(1:50)
    else
        CB_Is = collect(1:250)
    end
    global start = time_ns()
    global results[i,1], results[i,2], results[i,3:6], results[i,7:9], results[i,10:11], results[i,12], results[i,13], results[i,14], results[i,15], overbidder =  Main_stochastic_CC(CB_Is, 2)
    results_df = DataFrame(results, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\CVAR_tests.csv", results_df)
end
