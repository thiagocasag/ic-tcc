include("UnionFind.jl")
include("Kmeans.jl")
include("GTest.jl")

using RPCircuits
using Distributions: rand, truncated, Normal


#auxiliar function
function EstDist(dataset, var_index, inst_index_list, add_smooth_const::Float64 = 0.1)
    """
    input: a dataset represented as a matrix
            an index of the variable
            an array of indexes of instances
    output a node of an univariate distribution.
    """

    total_number_instances = size(dataset)[1]
    count_freq_dict = Dict()

    for i in 1:total_number_instances
        instance_value = dataset[i, var_index]
        if instance_value in keys(count_freq_dict)

            if i in inst_index_list
                count_freq_dict[instance_value] += 1
            end

        else

            if i in inst_index_list
                count_freq_dict[instance_value] = 1
            else
                count_freq_dict[instance_value] = 0
            end

        end
    end

    freq_list = Array{Float64, 1}(undef, 0)
    key_list = sort(collect(keys(count_freq_dict)))
    for key in key_list
        count = count_freq_dict[key]
        freq = ( count + add_smooth_const ) / ( length(inst_index_list) + add_smooth_const )
        push!(freq_list, freq)
    end

    freq_list = freq_list / (sum(freq_list))

    return Categorical(var_index, freq_list)
end

#auxiliar function
function VariableDep(dataset, index1::Int64, index2::Int64, inst_index_list::Array{Int64}, categorical = true, pval::Float64 = 0.0015)
    """
    input: dataset represented by a matrix, where each column represents a variable, and each row represents a sample.
            index1: index of the first variable
            index2: index of second variable
            inst_index_list: list of instances that will be considered to perform the independence test. 
            categorical: if true, performs a hypothesis test for discrete variables (G-test). If false, it performs a hypothesis test for continuous variables.
    output: true if variables are dependent. false if not.
    """

    return GTest(dataset, index1::Int64, index2::Int64, inst_index_list::Array{Int64}, pval)


end


function VariableSplit(dataset, inst_index_list::Array{Int64}, var_index_list::Array{Int64}, pval::Float64 = 0.0015)
    """
    input: dataset represented by a matrix, where each column represents a variable, and each row represents a sample (instance).
            array of indexes (of variables) to be splited.
    output: array S of arrays{Int64}. Every array in S is composed of indexes where the variables that corresponds to each index are dependent.

    Shortly, it performs an indepedence test on each pair of variables, more specifically, a G-test of pairwise independence. Then, it forms a graph G: each variable
    is represented by a node, and if they are dependent, they are connected. It ends up with a graph with k connected
    components, say, G_1, ... , G_k. The row 1 of matrix output will contain the (index of) variables in the component G_1 and row k will contain the variables in
    the component G_k.
    If the graph has only one connected component, it performs an instance split (and the output is the same as the input).
    """

    var_num = length(var_index_list)

    # create a list such that for every variable a UnionFindNode is created.
    nodes_list = []
    for i in 1:var_num
        index = var_index_list[i]
        push!( nodes_list, UnionFindNode(index) )
    end

    for node1 in nodes_list
        for node2 in nodes_list
            if node1 != node2
                index1 = node1.index
                index2 = node2.index
                if VariableDep(dataset, index1, index2, inst_index_list, pval) == true
                    Union(node1, node2)
                end
            end
        end
    end

    return CountComponents(nodes_list)

end


function InstanceSplit(dataset, inst_index_list::Array{Int64}, var_index_list::Array{Int64}, K::Int64 = 2)
    """
    input: dataset represented by a matrix (n x m)
            array of Int64, representing the indexes of variables
            array of Int64 representing the indexes of instances.
    output: array that contain arrays, which are the instances that are grouped together.

    This function performs a clustering using k-means.
    """
    
    cluster_list = Kmeans(dataset, var_index_list, inst_index_list, K)

    weight_list = Array{Float64, 1}(undef, 0)

    for element in cluster_list
        size_cluster_n = length(element)
        total_numb_inst = length(inst_index_list)
        push!(weight_list, size_cluster_n/total_numb_inst)
    end

    return cluster_list, weight_list

end


function LearnSPN(dataset, var_index_list::Array{Int64}, inst_index_list::Array{Int64}, pval::Float64 = 0.0015, add_smooth_const::Float64 = 0.1, K::Int64 = 2)
    """
    input: dataset represented by a matrix (n x m)
            array of Int64, representing the indexes of variables
            array of Int64 representing the indexes of instances.
            Hyperparameters: p-value for the dependency test;
                             laplace smoothing constant, for the distribution estimation;
                             K for the number of clusters in InstanceSplit 
    output: Probabilistic Circuit constructed based on dataset.
    """

    num_var = length(var_index_list)
    num_inst = length(inst_index_list)


    if num_var == 1
        index = var_index_list[1]
        return EstDist(dataset, index, inst_index_list, add_smooth_const)
    else
    
        var_split = VariableSplit(dataset, inst_index_list, var_index_list, pval)
        if length(var_split) > 1        #it means there are independent variables.

            list_sub_spn = Array{Node, 1}(undef, 0)
            for i in 1:length(var_split)
                push!( list_sub_spn, LearnSPN(dataset, var_split[i], inst_index_list, pval, add_smooth_const, K) )
            end

            return Product(list_sub_spn)

        else                            #it means all variables are pairwise dependent. Then, a clustering is performed.

            inst_split, weight_list = InstanceSplit(dataset, inst_index_list, var_index_list, K)

            list_sub_spn = Array{Node, 1}(undef, 0)
            for i in 1:length(inst_split)
                if inst_split[i] != []
                    push!( list_sub_spn, LearnSPN(dataset, var_index_list, inst_split[i], pval, add_smooth_const, K) )
                end
            end

            
            return Sum(list_sub_spn, weight_list)

        end
    end
end

