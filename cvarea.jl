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


### markersize bom = 2
### ponto a ponto bom: 0.05

function plot_circuit(PC; N=1000, limit=3)
    grid = [collect(i) for i in Iterators.product(LinRange(-limit,limit,N), LinRange(-limit,limit,N))]
    density = zeros(N,N)
    for i=1:N, j=1:N
        density[i,j] = PC(grid[i,j]) #exp(plogpdf(PC, grid[i,j]))
    end
    # heatmap(LinRange(-limit,limit,N),LinRange(-limit,limit,N),density)

    plot(aspect_ratio=1, xlimits=(-limit, limit), ylimits=(-limit, limit))

    # density_transposed = transpose(density)
    # contour(LinRange(-limit,limit,N),LinRange(-limit,limit,N),density_transposed, levels=40, lw=1)

    scatter!([0], [0], markersize=3, markercolor=:red1)
    scatter!([0], [1], markersize=3, markercolor=:green1)
    scatter!([1], [0], markersize=3, markercolor=:blue1)

    for k in -limit:0.025:limit
        for l in -limit:0.025:limit
            moda, n_iterations = ModalEM_iterations(PC, [k,l])
            if n_iterations > 4
                n_iterations = 4
            end

            if euclidean(moda, [0,0]) < 0.2
                cor = string("red", string(n_iterations))

                # plot!([k], [l], shape=shape(:rectangle, 3, 4), linecolor=cor, fillalpha=1, legend=false, markerstrokecolor=cor, markerstrokewidth=0)

                scatter!([k], [l], markersize=1, markercolor=cor, markershape=:square, markerstrokecolor=cor)
            elseif euclidean(moda, [0,1]) < 0.2
                cor = string("green", string(n_iterations))

                # plot!([k], [l], shape=shape(:rectangle, 3, 4), linecolor=cor, fillalpha=1, legend=false, markerstrokecolor=cor, markeralpha=1.0, markerstrokewidth=0)

                scatter!([k], [l], markersize=1, markercolor=cor, markershape=:square, markerstrokecolor=cor)
            elseif euclidean(moda, [1,0]) < 0.2
                cor = string("blue", string(n_iterations))

                # plot!([k], [l], shape=shape(:rectangle, 3, 4), linecolor=cor, fillalpha=1, legend=false, markerstrokecolor=cor, markeralpha=1.0, markerstrokewidth=0)

                scatter!([k], [l], markersize=1, markercolor=cor, markershape=:square, markerstrokecolor=cor)
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
    plot!(legend=false)
end