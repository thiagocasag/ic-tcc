include("UnionFind.jl")
include("Kmeans.jl")
include("GTest.jl")
include("LearnSPN.jl")

using RPCircuits 
using BenchmarkTools 
using Distributions: rand, truncated, Normal


function argmaximization(dicio_inferencia)
    most_probable_evidence_list = Array{Int64, 1}(undef, 0)
    key_list = sort(collect(keys(dicio_inferencia)))
    for key in key_list
        evidence = dicio_inferencia[key]
        push!(most_probable_evidence_list, evidence)
    end
    
    return most_probable_evidence_list
end



function LSPNscript()
    dataset_list = ["plants"]
    pval_list = [0.0015, 0.0001]
    additive_const_list = [0.2, 0.4, 0.6, 0.8]
    for dataset in dataset_list
        constante = 0
        m_train, m_valid, m_test = twenty_datasets(dataset, as_df = false)     #matrixes
        n_rows, m_cols = size(m_train)
        inst_list, var_list = [i for i in 1:n_rows], [j for j in 1:m_cols]
        for pval in pval_list
            for add_const in additive_const_list
                    ###tempo gasto para a construção do circuito cada dataset
                    print("             Dataset: ", dataset, "\n")
                    print("Hiperparametros: \n pval: ", pval, "\n add_const: ", add_const, "\n")
                    print("TEMPO (MINIMO) DE CONSTRUCAO DO CIRCUITO\n")
                    if constante == 0
                        @btime LearnSPN($m_train, $var_list, $inst_list, $pval, $add_const)
                    end
                
                    print("\n\n")

                    ###tempo gasto com a realizaçao de inferencia MAP
                    print("TEMPO MINIMO GASTO COM INFERENCIA MAP:\n")
                    S = LearnSPN(m_train, var_list, inst_list, pval, add_const)
                    NaN_list = [NaN for i in 1:n_rows]
                    if constante == 0
                        @btime maxproduct($S, $NaN_list)
                    end

                    constante += 1

                    print("\n\n")

                    ###valores da inferencia (sao tres para cada configuração)
                    for i in 1:4
                        print("valor de inferencia: TESTE ", i, ":\n")
                        S = LearnSPN(m_train, var_list, inst_list, pval, add_const)
                        print("numero de nós: ", length(nodes(S)), "\n")
                       infer = maxproduct(S, NaN_list).evidence
                       MPE = argmaximization(infer)
                       log_MPE = log(S(MPE))
                       print("inferencia MAP: ", log_MPE, "\n\n")
                    end

                    print("\n\n\n")

                
            end
        end
    end

end