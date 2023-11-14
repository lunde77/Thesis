using Random
function make_folds(NF)
    Fold_size = Int32(floor(365/NF) )
    Random.seed!(3) # set this to a number if we want to have same in sample and out sample across samples
    sampled_numbers_tester = randperm(length(collect(1:365)))
    sampled_numbers = zeros(NF, (NF-1)*Fold_size)
    OOS_numbers = zeros(NF, Fold_size)
    folds = zeros(NF, Fold_size)
    for e=1:NF
        folds[e,:] = sampled_numbers_tester[(e-1)*Fold_size+1:Fold_size*e]
    end

    for e=1:NF
        original_vector = collect(1:NF)

        # Use filter to remove the specified number
        In_folder = filter(x -> x != e, original_vector)
        global new_vector = Int[]
        println(In_folder)
        for q in In_folder
             global k_fold = folds[q,:]
             global new_vector = vcat(new_vector, k_fold)
        end
        sampled_numbers[e,:] = new_vector
        OOS_numbers[e,:] = folds[e,:]
    end
    sampled_numbers = Int.(sampled_numbers)
    OOS_numbers = Int.(OOS_numbers)
    sampled_numbers, OOS_numbers
end
