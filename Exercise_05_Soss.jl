### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ b5cce6ce-750b-11eb-3bd1-8b88d1f2febe
begin
	using Soss # https://github.com/cscherrer/Soss.jl
	using Random
	using Plots
end

# ╔═╡ d5a648b8-7525-11eb-0eec-ad7fc25eaa4b
md""""
This version uses Soss https://github.com/cscherrer/Soss.jl
* generate data from true parameters
* describe model with priors
* fit model to true data
* examine mcmc diagnostics
* examine results
"""

# ╔═╡ a8e8be46-750c-11eb-30d0-253893696e5e
md"""
JAGS model for comparison:
```
model{

  b ~ dmnorm(b0,Pb)  	## multivariate Normal prior on vector of regression params
  S ~ dgamma(s1,s2)    ## prior precision

  for(i in 1:n){
	  mu[i] <- b[1] + b[2]*x[i]   	    ## process model
	  y[i]  ~ dnorm(mu[i],S)		        ## data model
  }
}

data$b0 <- as.vector(c(0,0))      ## regression b means
data$Vb <- solve(diag(10000,2))   ## regression b precisions
data$s1 <- 0.1                    ## error prior n/2
data$s2 <- 0.1                    ## error prior SS/2
```
"""

# ╔═╡ 01446c80-750c-11eb-2c03-734dde901334
## Translating these JAGS results, get parameters, generate data:

## 1. Empirical mean and standard deviation for each variable,
##    plus standard error of the mean:
## 
##         Mean       SD  Naive SE Time-series SE
## S    0.06067 0.008597 7.399e-05      7.718e-05
## b[1] 9.74584 0.901385 7.757e-03      7.839e-03
## b[2] 2.01577 0.076636 6.595e-04      6.504e-04

begin 
	N = 100
	x_seq = collect(range(0, stop = 20, length = N)) # needs to be in array form for the sampler
	α = 9.75
	β = 2.0
	σ = 4.0 # precision -> sd: 1 / sqrt(S)
	y_true = α.+randn(N) .+ (β .+ randn(N)*0.07) .* x_seq .+ σ.*randn(N) # Create data
	# we could probably use a @model to generate these in simpler way?
end

# ╔═╡ 3f496892-7513-11eb-20d0-b3a77da5dfa0
scatter(x_seq, y_true)

# ╔═╡ cf02f2e0-7516-11eb-3df7-57ae6ccdd9c1
X = collect(range(0,stop=20, length=1000))

# ╔═╡ c553fe36-750e-11eb-17a4-6d727dedcef6
# Define Soss model, distributions seem to be from Distributions.jl

model = @model X begin
	α ~ Normal(0,100) # prior for the intercept α (β0) 
	β ~ Normal(0,100) # prior for the slope β (β1)
	σ ~	Gamma(3, 3) # error as standard deviation (instead of precision)
	μ = α .+ β.*X  # linear model for mean μ
	y ~ For(eachindex(μ)) do i  # For() seems to be a Soss-function, eachindex() is a standard Julia function
		Normal(μ[i], σ)  # likelihood function
	end
end



# ╔═╡ f20d56f4-750c-11eb-3378-658e78bdac06
forward_sample = rand(model(X=X)) # get a single sample from the prior distribution

# ╔═╡ 8ab2ba9a-750d-11eb-13f0-c55d24899e79
pairs(forward_sample) # another way to output, might work better in terminal

# ╔═╡ 6db13352-7517-11eb-1140-0f3e4e8d7186
scatter(range(0,stop=20,	length=1000), forward_sample.y) # prior predictive plot

# or this is one parameter sample only, no monte carlo here yet

# ╔═╡ be2085ce-7529-11eb-3cfe-93e81c473b89
histogram(rand(Gamma(3, 3), 1000)) # prior predictive for σ, 1/sqrt(0.1) ~ 3, is this fine?

# ╔═╡ 917322e2-7516-11eb-1ffa-71f3eb54d59d
# Hamiltonian Monte Carlo to get posterior disribution for parameters
posterior = dynamicHMC(model(X=x_seq,), (y=y_true,))

# ╔═╡ 058d0bac-7517-11eb-2097-7bfb1b6863d8
# a way to summarize, see https://github.com/baggepinnen/MonteCarloMeasurements.jl
# compare to true parameters, set above when generating data
particles(posterior) 


# ╔═╡ Cell order:
# ╠═d5a648b8-7525-11eb-0eec-ad7fc25eaa4b
# ╠═b5cce6ce-750b-11eb-3bd1-8b88d1f2febe
# ╠═a8e8be46-750c-11eb-30d0-253893696e5e
# ╠═c553fe36-750e-11eb-17a4-6d727dedcef6
# ╠═01446c80-750c-11eb-2c03-734dde901334
# ╠═3f496892-7513-11eb-20d0-b3a77da5dfa0
# ╠═cf02f2e0-7516-11eb-3df7-57ae6ccdd9c1
# ╠═f20d56f4-750c-11eb-3378-658e78bdac06
# ╠═8ab2ba9a-750d-11eb-13f0-c55d24899e79
# ╠═6db13352-7517-11eb-1140-0f3e4e8d7186
# ╠═be2085ce-7529-11eb-3cfe-93e81c473b89
# ╠═917322e2-7516-11eb-1ffa-71f3eb54d59d
# ╠═058d0bac-7517-11eb-2097-7bfb1b6863d8
