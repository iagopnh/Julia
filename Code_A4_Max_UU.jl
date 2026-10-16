################################################################
# Modelos CGE com Julia - Prof. Christiano Penna
# Contato: cmp@caen.ufc.br   (85) 99736-6006
# Maximização da Utilidade (Aula 4)
################################################################

# using Pkg
# Pkg.add("JuMP")
# Pkg.add("Ipopt")

using JuMP
using NLopt

# Definindo os dados
i = ["BRD", "MLK"]  # Bens
h = ["CAP", "LAB"]  # Fatores

# Parâmetros
alpha = Dict("BRD" => 0.3, "MLK" => 0.7)
px = Dict("BRD" => 1.0, "MLK" => 2.0)
pf = Dict("CAP" => 2.0, "LAB" => 1.0)
FF = Dict("CAP" => 10.0, "LAB" => 30.0)

# Criando o modelo de otimização
model = Model(NLopt.Optimizer)
set_attribute(model, "algorithm", :LD_MMA)
set_attribute(model, "xtol_rel", 1e-4)
set_attribute(model, "constrtol_abs", 1e-8)

# Variáveis de consumo (X) - consumo de cada bem
@variable(model, X[i] >= 0.000001)  # Cria X como um vetor indexado pelos bens

# Função objetivo: Maximizar a utilidade (produto dos bens consumidos elevado ao seu respectivo alpha)
@objective(model, Max, prod(X[j]^alpha[j] for j in i))

# Restrições: Função de demanda para cada bem
for j in i
    @constraint(model, X[j] == alpha[j] * sum(pf[k] * FF[k] for k in h) / px[j])
end

# Resolvendo o modelo
optimize!(model)

# Impressão dos Resultados
println("Resultado ótimo de consumo:")
for j in i
    println("$j: ", value(X[j]))
end
println("Utilidade: ", objective_value(model))
