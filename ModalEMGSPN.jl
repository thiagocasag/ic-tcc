include("UnionFind.jl")
include("Kmeans.jl")
include("GTest.jl")
include("LearnSPN.jl")

using Random
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


# function ModalEM(x_r, gspn)
#     # Inicializa o valor de x(r+1) com x_r
#     # x_r_plus_1 = copy(x_r)
    
#     # Cria um dicionário para armazenar os valores N e D para cada variável aleatória
#     N = Dict()
#     D = Dict()
    
#     # Inicializa os valores N e D para cada variável aleatória
#     for v in nodes(gspn)
#         for z in scope(v)
#             N[(v, z)] = 1.0
#             D[(v, z)] = 1.0
#         end
#     end
    
#     # Percorre os nós em ordenação topológica reversa
#     for v in nodes(gspn)
#         if isleaf(v)
#             # Se o nó é uma folha, obtemos os parâmetros e o valor da gaussiana
#             y = variable_in_scope(v)
#             μ, σ = v.mean, v.variance
#             v_x_ry = value_of_subcircuit(v, x_r)
            
#             # Calcula os valores Nvy e Dvy
#             N[(v, y)] = (v_x_ry * μ) / σ^2
#             D[(v, y)] = v_x_ry / σ^2
            
#             # Calcula os valores Nvz e Dvz para todas as variáveis z != y no escopo do nó
#             for z in scope(v)
#                 if z != y
#                     N[(v, z)] = D[(v, z)] = v_x_ry
#                 end
#             end
#         elseif isprod(v)
#             # Se o nó é um nó de produto, calcula os valores Nvz e Dvz para todas as variáveis z
#             for z in scope(v)
#                 N[(v, z)] = D[(v, z)] = 1.0
#                 for c in children(v)
#                     N[(v, z)] *= N[(c, z)]
#                     D[(v, z)] *= D[(c, z)]
#                 end
#             end
#         elseif issum(v)
#             # Se o nó é um nó de soma, calcula os valores Nvz e Dvz para todas as variáveis z
#             for z in scope(v)
#                 N[(v, z)] = D[(v, z)] = 0.0
#                 n_children = size(v.children)[1]
#                 for i in 1:n_children
#                     N[(v, z)] += v.weights[i] * N[(v.children[i], z)]  #ERRO NO NODE WEIGHT 
#                     D[(v, z)] += v.weights[i] * D[(v.children[i], z)]  #SAME
#                 end
#             end
#         end
#     end
    
#     # Retorna o resultado final
#     return N[(root_node(gspn), x_r)] / D[(root_node(gspn), x_r)]
# end



# function modal_em_gspn(x_r, gspn)
#     N = Dict{Tuple{Any, Any}, Float64}()
#     D = Dict{Tuple{Any, Any}, Float64}()
    
#     modal_em_gspn_recursive(x_r, gspn, N, D)
    
#     return N[(gspn, x_r)] / D[(gspn, x_r)]
# end

# function modal_em_gspn_recursive(x_r, node, N, D)
#     for z in scope(node)
#         N[(node, z)] = 0.0
#         D[(node, z)] = 0.0
#     end
    
#     if isleaf(node)
#         y = scope(node)
#         μ, σ = node.mean, node.variance
#         v_x_ry = value_of_subcircuit(node, x_r)
        
#         N[(node, y)] = (v_x_ry * μ) / σ^2
#         D[(node, y)] = v_x_ry / σ^2
        
#         for z in scope(node)
#             if z != y
#                 N[(node, z)] = D[(node, z)] = v_x_ry
#             end
#         end
#     elseif isprod(node)
#         for c in children(node)
#             modal_em_gspn_recursive(x_r, c, N, D)
#         end
        
#         for z in variables_in_scope(node)
#             N[(node, z)] = D[(node, z)] = 1.0
#             for c in children(node)
#                 N[(node, z)] *= N[(c, z)]
#                 D[(node, z)] *= D[(c, z)]
#             end
#         end
#     elseif issum(node)
#         for c in children(node)
#             modal_em_gspn_recursive(x_r, c, N, D)
#         end
        
#         for z in scope(node)
#             N[(node, z)] = D[(node, z)] = 0.0
#             n_children = size(node.children)[1]
#             for i in 1:n_children
#                 N[(node, z)] += node.weights[i] * N[(node.children[i], z)]
#                 D[(node, z)] += node.weights[i] * D[(node.children[i], z)]
#             end
#         end
#     end
# end


function modal_em_simple(x_r, max_iterations=100, epsilon=0.001)
    x_prev = copy(x_r)
    for iteration in 1:max_iterations
        x_new = similar(x_r)
        
        for i in 1:length(x_r)
            y = i  # Simplesmente considerando y como a dimensão i
            
            # Cálculos dos termos N e D para o nó folha
            N_yv = value_of_subcircuit(y, x_r)  # Substitua por seus cálculos reais
            D_yv = value_of_subcircuit(y, x_r)  # Substitua por seus cálculos reais
            
            N_v = fill(D_yv, length(x_r))
            D_v = fill(D_yv, length(x_r))
            N_v[y] = N_yv
            
            for z in 1:length(x_r)
                if z != y
                    N_v[z] = D_v[z] = value_of_subcircuit(y, x_r)  # Substitua por seus cálculos reais
                end
            end
            
            x_new[i] = N_v[y] / D_v[y]  # Atualiza a dimensão i de x_new
        end
        
        distance = norm(x_prev - x_new)
        if distance < epsilon
            return x_new
        end
        
        x_prev .= x_new
    end
    
    return x_prev
end

# Exemplo de uso
x_r = [1.0, 1.0]  # Ponto inicial

result = modal_em_simple(x_r)
println("Resultado: ", result)

