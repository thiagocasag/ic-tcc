include("UnionFind.jl")
include("Kmeans.jl")
include("GTest.jl")
include("NormalTest.jl")
include("LearnSPN.jl")

using Distributions
using Plots
using StatsPlots
using RPCircuits


function GenerateData(GMM, dataset_size)
    return rand(GMM, dataset_size)
end



function GenerateFromGMM(GMM, list_dsizes)
    """
    input: GMM, list of sizes of each dataset
    output: plots from a GSPN 
    """

    for size in list_dsizes
        dataset = GenerateData(GMM, size)    #matrix 2xsize
        
    end
end