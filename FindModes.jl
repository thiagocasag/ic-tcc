include("UnionFind.jl")
include("Kmeans.jl")
include("GTest.jl")
# include("NormalTest.jl")
include("LearnSPN.jl")
include("MODALEM.jl")

using Random
using Distances
using Distributions
using Plots
using StatsPlots
using RPCircuits

function FindModes(gspn, limit = 2)
    for i in -limit:0.05:limit
        for j in -limit:0.05:limit
            moda = ModalEM_iterations(gspn, [i,j])
            print(moda)
            print("\n")
        end
    end
end

function plot_circuit(PC; N=1000, limit=4)
    grid = [collect(i) for i in Iterators.product(LinRange(-limit,limit,N), LinRange(-limit,limit,N))]
    density = zeros(N,N)
    for i=1:N, j=1:N
        density[i,j] = PC(grid[i,j]) #exp(plogpdf(PC, grid[i,j]))
    end
    # heatmap(LinRange(-limit,limit,N),LinRange(-limit,limit,N),density)
    density_transposed = transpose(density)
    contour(LinRange(-limit,limit,N),LinRange(-limit,limit,N),density_transposed, levels=40, lw=1)

    for i in -limit:0.1:limit
        for j in -limit:0.1:limit
            moda = ModalEM_iterations(PC, [i,j])[1]
            scatter!([moda[1]], [moda[2]], markersize=3, markercolor=:red)
        end
    end
end

function example3()

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

    # savefig(a, "plot_3gauss_converg")

    # ModalEM_iterations(sum_node, [2,2])


end