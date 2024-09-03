include("UnionFind.jl")
include("Kmeans.jl")
include("GTest.jl")
# include("NormalTest.jl")
include("LearnSPN.jl")

using Random
using Distances
using Distributions
using Plots
using StatsPlots
using RPCircuits


function value_of_subcircuit(node, vector_values)
    if issum(node)
        value = 0
        n_children = size(node.children)[1]
        for i in 1:n_children
            value += node.weights[i] * value_of_subcircuit(node.children[i], vector_values)
        end
    elseif isprod(node)
        value = 1
        n_children = size(node.children)[1]
        for i in 1:n_children
            value *= value_of_subcircuit(node.children[i], vector_values)
        end
    else
        value = node(vector_values)
    end

    return value
end

function ModalEM(gspn, x_0)

    N_dict = Dict()
    D_dict = Dict()
    for node in nodes(gspn)
        N_dict[node] = [0.001,0.001]
        D_dict[node] = [0.001,0.001]
    end

    for node in nodes(gspn)
        if isleaf(node)
            value = value_of_subcircuit(node, x_0)
            scope_node = node.scope
            mean = node.mean
            var = node.variance

            for scopez in scope(gspn)
                if scopez == scope_node
                    N_dict[node][scope_node] = (value * mean) / var
                    D_dict[node][scope_node] = (value) / var
                else
                    N_dict[node][scopez] = value
                    D_dict[node][scopez] = value
                end
            end

            # print(node)
            # print("\n")
            # print(N_dict[node])
            # print("\n")
            # print(D_dict[node])
            # print("\n")
        end
    end


    for node in nodes(gspn)
        if isprod(node)
            N_dict[node] = [1.0,1.0]
            D_dict[node] = [1.0,1.0]
            for scope in scope(gspn)
                n_children = length(children(node))
                for j in 1:n_children
                    N_dict[node][scope] *= N_dict[ children(node)[j] ][scope]
                    D_dict[node][scope] *= D_dict[ children(node)[j] ][scope]
                end
            end

        # print(node)
        # print("\n")
        # print(N_dict[node])
        # print("\n")
        # print(D_dict[node])
        # print("\n")

        end
    end

    for node in nodes(gspn)
        if issum(node)
            for scope in scope(gspn)
                n_children = length(children(node))
                for j in 1:n_children
                    N_dict[node][scope] += node.weights[j] * N_dict[ children(node)[j] ][scope]
                    D_dict[node][scope] += node.weights[j] * D_dict[ children(node)[j] ][scope]
                end
            end
        end
    end

    # print(N_dict[gspn])
    # print(D_dict[gspn])

    # print( [N_dict[gspn][1]/D_dict[gspn][1] ,N_dict[gspn][2]/D_dict[gspn][2] ] )
    # print("\n")

    return [ N_dict[gspn][1]/D_dict[gspn][1] ,N_dict[gspn][2]/D_dict[gspn][2]  ]
end


function ModalEM_iterations(gspn, x_0)

    # print(x_0)

    number_of_iterations = 0

    x_1 = ModalEM(gspn, x_0)
    flagx1 = true

    number_of_iterations += 1

    # print(x_1)
    # print("\n")

    while euclidean(x_0, x_1) > 0.01
        if flagx1 == true
            x_0 = ModalEM(gspn, x_1)
            flagx1 = false

            number_of_iterations += 1

            # print(x_0)
            # print("\n")
        else
            x_1 = ModalEM(gspn, x_0)
            flagx1 = true

            number_of_iterations += 1

            # print(x_1)
            # print("\n")
        end
    end

    return x_1, number_of_iterations
        
end