include("UnionFind.jl")
include("Kmeans.jl")
include("GTest.jl")
# include("NormalTest.jl")
include("LearnSPN.jl")
include("MODALEM.jl")
# include("FindModes.jl")

using Random
using Distances
using Distributions
using Plots
using StatsPlots
using RPCircuits

function plot_circuit(PC; N=800, limit=4)
    # grid = [collect(i) for i in Iterators.product(LinRange(-limit,limit,N), LinRange(-limit,limit,N))]
    # density = zeros(N,N)
    # for i=1:N, j=1:N
    #     density[i,j] = PC(grid[i,j]) #exp(plogpdf(PC, grid[i,j]))
    # end
    ## heatmap(LinRange(-limit,limit,N),LinRange(-limit,limit,N),density)
    # density_transposed = transpose(density)
    # contour(LinRange(-limit,limit,N),LinRange(-limit,limit,N),density_transposed, levels=10, lw=1)
    plot(xlimits = (-4,4), ylimits = (-4,4))
    scatter!([0], [0], markersize=3, markercolor=:red1)
    scatter!([0], [1], markersize=3, markercolor=:green1)
    scatter!([1], [0], markersize=3, markercolor=:blue1)

    for i in -limit:0.2:limit
        for j in -limit:0.2:limit
            moda, n_iterations = ModalEM_iterations(PC, [i,j])
            if n_iterations > 4
                n_iterations = 4
            end

            if euclidean(moda, [0,0]) < 0.001
                # cor = string("red", string(n_iterations))
                # scatter!([i], [j], markersize=3, markercolor=cor, markershape=:square, markerstrokecolor=cor)
                scatter!([i], [j], markersize=3, markercolor=red, markershape=:square, markerstrokecolor=red)
            elseif euclidean(moda, [0,1]) < 0.001
                # cor = string("green", string(n_iterations))
                # scatter!([i], [j], markersize=3, markercolor=cor, markershape=:square, markerstrokecolor=cor)
                scatter!([i], [j], markersize=3, markercolor=green, markershape=:square, markerstrokecolor=green)
            elseif euclidean(moda, [1,0]) < 0.001
                # cor = string("blue", string(n_iterations))
                # scatter!([i], [j], markersize=3, markercolor=cor, markershape=:square, markerstrokecolor=cor)
                scatter!([i], [j], markersize=3, markercolor=blue, markershape=:square, markerstrokecolor=blue)
            end
        end
    end
end



function example()
    #LIMIT = 3 !!!!!!!!
    x = Gaussian(1, 1, 1)
    y = Gaussian(2, 0, 0.1)
    z = Gaussian(1, 0, 0.1)
    w = Gaussian(2, 1, 1)

    P1 = RPCircuits.Product([x,y])
    P2 = RPCircuits.Product([z,w])

    S = Sum([P1,P2], [0.5, 0.5])

    a = plot_circuit(S)
    # plot!(legend=false)
end