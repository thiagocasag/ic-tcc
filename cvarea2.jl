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

function plot_circuit(PC; N=1000, limit=2)
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
    scatter!([1], [0], markersize=3, markercolor=:green1)
    scatter!([0.5], [sqrt(3)/2], markersize=3, markercolor=:blue1)
    scatter!([0.25], [0.5], markersize=3, markercolor=:purple1)
    scatter!([0.5], [0], markersize=3, markercolor=:yellow1)
    scatter!([0.75], [0.5], markersize=3, markercolor=:lightsalmon1)
    scatter!([0.5], [sqrt(3)/6], markersize=3, markercolor=:chocolate1)
    

    for k in -limit:0.025:limit
        for l in -limit:0.025:limit
            moda, n_iterations = ModalEM_iterations(PC, [k,l])
            if n_iterations > 4
                n_iterations = 4
            end

            if euclidean(moda, [0,0]) < 0.2
                cor = string("red", string(n_iterations))

                # plot!([k], [l], shape=shape(:rectangle, 3, 4), linecolor=cor, fillalpha=1, legend=false, markerstrokecolor=cor, markerstrokewidth=0)

                scatter!([k], [l], markersize=2, markercolor=cor, markershape=:square, markerstrokecolor=cor)

            elseif euclidean(moda, [1,0]) < 0.2
                cor = string("green", string(n_iterations))

                # plot!([k], [l], shape=shape(:rectangle, 3, 4), linecolor=cor, fillalpha=1, legend=false, markerstrokecolor=cor, markeralpha=1.0, markerstrokewidth=0)

                scatter!([k], [l], markersize=2, markercolor=cor, markershape=:square, markerstrokecolor=cor)

            elseif euclidean(moda, [0.5,sqrt(3)/2]) < 0.2
                cor = string("blue", string(n_iterations))

                # plot!([k], [l], shape=shape(:rectangle, 3, 4), linecolor=cor, fillalpha=1, legend=false, markerstrokecolor=cor, markeralpha=1.0, markerstrokewidth=0)

                scatter!([k], [l], markersize=2, markercolor=cor, markershape=:square, markerstrokecolor=cor)

            elseif euclidean(moda, [0.25, 0.5]) < 0.2
                cor = string("purple", string(n_iterations))

                # plot!([k], [l], shape=shape(:rectangle, 3, 4), linecolor=cor, fillalpha=1, legend=false, markerstrokecolor=cor, markeralpha=1.0, markerstrokewidth=0)

                scatter!([k], [l], markersize=2, markercolor=cor, markershape=:square, markerstrokecolor=cor)

            elseif euclidean(moda, [0.5, 0]) < 0.2
                cor = string("yellow", string(n_iterations))

                # plot!([k], [l], shape=shape(:rectangle, 3, 4), linecolor=cor, fillalpha=1, legend=false, markerstrokecolor=cor, markeralpha=1.0, markerstrokewidth=0)

                scatter!([k], [l], markersize=2, markercolor=cor, markershape=:square, markerstrokecolor=cor)

            elseif euclidean(moda, [0.75, 0.5]) < 0.2
                cor = string("lightsalmon", string(n_iterations))

                # plot!([k], [l], shape=shape(:rectangle, 3, 4), linecolor=cor, fillalpha=1, legend=false, markerstrokecolor=cor, markeralpha=1.0, markerstrokewidth=0)

                scatter!([k], [l], markersize=2, markercolor=cor, markershape=:square, markerstrokecolor=cor)

            elseif euclidean(moda, [0.5, sqrt(3)/6]) < 0.2
                cor = string("chocolate", string(n_iterations))

                # plot!([k], [l], shape=shape(:rectangle, 3, 4), linecolor=cor, fillalpha=1, legend=false, markerstrokecolor=cor, markeralpha=1.0, markerstrokewidth=0)

                scatter!([k], [l], markersize=2, markercolor=cor, markershape=:square, markerstrokecolor=cor)
            end
        end
    end
end


function example2()

    x1, x2 = Gaussian(1, 0.0, 0.1), Gaussian(2, 0.0, 0.1)
    y1, y2 = Gaussian(1, 1.0, 0.1), Gaussian(2, 0.0, 0.1)
    z1, z2 = Gaussian(1, 0.5, 0.1), Gaussian(2, sqrt(3)/2, 0.1)

    P1 = RPCircuits.Product([x1, x2])
    P2 = RPCircuits.Product([y1, y2])
    P3 = RPCircuits.Product([z1, z2])


    sum_node = Sum([P1, P2, P3], [1/3, 1/3, 1/3])

    plot_circuit(sum_node)
    a = plot_circuit(sum_node)
    plot!(legend=false)
end