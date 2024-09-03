
function GTest(dataset, index1::Int64, index2::Int64, index_inst_list::Array{Int64}, pval::Float64 = 0.0015) 
    """
    Hypothesis test for discrete variables.
    
    index1 and index2 are indexes for variables 1 and 2 in the dataset, respectively.
    """

    instances_num = length(index_inst_list)                   #number of instances.
    count_var1 = Dict{Float64, Float64}()     #dict to count the number of times each value appeared in each instance of variable 1.
    count_var2 = Dict{Float64, Float64}()     #dict to count the number of times each value appeared in each instance of variable 2.
    count_tuple = Dict{Tuple{Float64, Float64}, Float64}()    #dict to count the number of times each pair (tuple) appeared in each instance of variable1 x variable2.

    for i in 1:instances_num
        #fill count_tuple
        inst_index = index_inst_list[i]
        tup = (dataset[inst_index, index1], dataset[inst_index, index2])
        if tup in keys(count_tuple)
            count_tuple[tup] += 1.0
        else
            count_tuple[tup] = 1.0
        end
        

        #fill count_var1
        if dataset[inst_index, index1] in keys(count_var1)
            count_var1[dataset[inst_index, index1]] += 1.0
        else
            count_var1[dataset[inst_index, index1]] = 1.0
        end

        #fill count_var2
        if dataset[inst_index, index2] in keys(count_var2)
            count_var2[dataset[inst_index, index2]] += 1.0
        else
            count_var2[dataset[inst_index, index2]] = 1.0
        end
    end

    g_statistics = 0
    for key in keys(count_tuple)
        inst_pair_count = count_tuple[key]
        inst_var1_count = count_var1[key[1]]
        inst_var2_count = count_var2[key[2]]
        g_statistics += inst_pair_count * (log((inst_pair_count * instances_num)/(inst_var1_count * inst_var2_count) ) )
    end

    g_statistics *= 2

    return g_statistics >= pval

end