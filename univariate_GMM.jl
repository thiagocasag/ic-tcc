using Distributions
using Plots

# Parâmetros das gaussianas
μ1, σ1 = 0, sqrt(0.1)
μ2, σ2 = 2.0, 1

# Criação das distribuições gaussianas
gaussian1 = Normal(μ1, σ1)
gaussian2 = Normal(μ2, σ2)

# Valores do eixo x
x_values = range(minimum([μ1 - 3σ1, μ2 - 3σ2]), maximum([μ1 + 3σ1, μ2 + 3σ2]), length=100)

# Valores das densidades de probabilidade (PDF)
pdf_mixture = [pdf(gaussian1, x) * 0.2 + pdf(gaussian2, x) * 0.8 for x in x_values]

# Ponto de mínimo
min_x = 0.674
min_y = pdf(gaussian1, min_x) * 0.2 + pdf(gaussian2, min_x) * 0.8
max_y = pdf(gaussian1, 2) * 0.2 + pdf(gaussian2, 2) * 0.8


# Plotagem do gráfico
plot(x_values, pdf_mixture, label="GSPN", color=:green)
scatter!([min_x], [min_y], marker=:circle, markersize=4, color=:red; label="ponto de minimo")
scatter!([2], [max_y], marker=:circle, markersize=4, color=:blue; label= "moda")
# xlabel!("Valores")
# ylabel!("Densidade de Probabilidade")
# title!("Mistura de Duas Gaussianas com Ponto de Mínimo")
# legend()

savefig("GMM_exemplo2.png")
