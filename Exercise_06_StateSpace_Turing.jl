### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ a1582e64-7b2c-11eb-1fee-db9d590b0564
begin
	using Turing # https://turing.ml
	using ReverseDiff # Unclear if this makes a difference
	using Random
	using StatsPlots, Downloads, CSV, DataFrames
	using PlutoUI
end

# ╔═╡ 32260a78-7b44-11eb-3285-99284e936aac
html"""<style>
main {
    max-width: 1300px;
}
"""

# ╔═╡ e5a57830-7b2c-11eb-3940-b9936b5a115c
# Get the Google Flu data
begin
	url1 = "https://raw.githubusercontent.com/EcoForecast/EF_Activities/master/data/gflu_data.txt"
	temp_file = Downloads.download(url1) # Download the file to a temporary location	
end

# ╔═╡ f90ca068-7b2c-11eb-266c-fd255604c322
df_flu = CSV.File(temp_file, header=11) |> DataFrame # make DataFrame out of CSV parser output

# ╔═╡ fa55548c-7b2c-11eb-02d3-e3d5a289f79e
plot(df_flu.Date, df_flu[:,"Massachusetts"], yscale=:log) # Two ways of accessing a single column

# ╔═╡ ff034744-7b2c-11eb-212b-53ff285f2069
md"""
Jags version
```
RandomWalk = "
model{
  
  #### Data Model
  for(t in 1:n){
    y[t] ~ dnorm(x[t],tau_obs)
  }
  
  #### Process Model
  for(t in 2:n){
    x[t]~dnorm(x[t-1],tau_add)
  }
  
  #### Priors
  x[1] ~ dnorm(x_ic,tau_ic)
  tau_obs ~ dgamma(a_obs,r_obs)
  tau_add ~ dgamma(a_add,r_add)
}
"
```
"""


# ╔═╡ f7304396-7b33-11eb-0f81-a74f2abd2551


# ╔═╡ 12ab529c-87c5-11eb-29a2-bb564464bcf1
plot(sqrt.(rand(InverseGamma(2,3), 100)), seriestype=:histogram) # See what a square root of an inverse gamma looks like (prior for errors)

# ╔═╡ 47a5ccba-7b2d-11eb-33ea-2f63b1b42daa
# Random walk model
#
# The function signature needs some special magic to work right:
# https://turing.ml/dev/docs/using-turing/performancetips#ensure-that-types-in-your-model-can-be-inferred   
# See also Julia parametric methods: https://docs.julialang.org/en/v1/manual/methods/#Parametric-Methods
@model random_walk(y, ::Type{T} = Float64) where {T} = begin
	N = length(y)
	X = Vector{T}(undef, N) # this apparently is the correct way to intialize a placeholder for X in Turing
	#X = zeros(Float64, N)
	#X = zeros(N) # throws an error
	#X = tzeros(undef,N) # doesn't work?
	#X = tzeros(Real,N) # slooow?
	X[1] ~ Normal(6,1) 
	
	#σ_add ~ Exponential(5)  
	#σ_obs ~ Exponential(5) 
	
	# Turing example uses inverse gamma with sqrt, seems to converge better than exponential,
	σ_add ~	InverseGamma(2,3) # 
	σ_obs ~ InverseGamma(2,3) 
	
	
	for t in 2:N 
		X[t] ~ Normal(X[t-1], sqrt(σ_add))  # with InverseGamma
		#X[t] ~ Normal(X[t-1], σ_add)  # with Exponential
	end	
	
	for t in 1:N 
		y[t] ~ Normal(X[t], sqrt(σ_obs))
		#y[t] ~ Normal(X[t], σ_obs)
	end
	
end

# ╔═╡ 7f156b5a-7b2e-11eb-16b8-05c4cda49df0
data = df_flu[:,"Massachusetts"]

# ╔═╡ a4bc9064-7b43-11eb-1521-17658b37fcc5
data_short = data[1:50] # Let's make a shorter one to fit faster

# ╔═╡ d0af2f52-87d9-11eb-21c7-bfe1a786394e
pred_model = random_walk(log.(data_short)) # initialize the model with data. Use the logarithm

# ╔═╡ 24a7e008-7b2e-11eb-0a55-a9dba9549591
begin
	iterations = 1000
	
	# Settings of the Hamiltonian Monte Carlo (HMC) sampler.
	ϵ = 0.05 # HMC leapfrog size
	τ = 15 # HMC leapfrog count
	
	hmc = HMC(ϵ, τ) # been tweaking this but, no luck,  30s doens't sample right
	pg = PG(20) #50s, doesn't seem to get X right at all, just keeps walking in random
	nuts = NUTS(1000, 0.65) # defaults, 1000 adaptation steps, 0.65 acceptance ratio, 60s, results look fine
	
	# Start sampling.
	sampler = nuts # This seems to work best of these
	
	chain = sample(pred_model, sampler, MCMCThreads(), iterations, 3, progress=false); 
	
end

# ╔═╡ ab1be9c4-87c0-11eb-15f9-330576f3bdd9
get(chain, :X) # There is a way to get all the Xs in one go after all.

# ╔═╡ 185983c2-833e-11eb-0561-c3e0b9f2568f
DataFrame(describe(chain)[1])

# ╔═╡ 1b6a29e2-80b5-11eb-2796-27a01e45ef1b
chn_prior = sample(pred_model, Prior(), 100)

# ╔═╡ 54e561e6-80b5-11eb-0c7d-e11f8eee62b1
DataFrame(describe(chn_prior)[1])

# ╔═╡ edd5d0d4-7b42-11eb-1ffa-d5f7ede144c5
names(chain)

# ╔═╡ d255f1f0-7b41-11eb-3a4a-0f582290c994
p_summary = chain[:σ_add]

# ╔═╡ f6b3c8fc-8590-11eb-174d-81f3f378b649
get(chain, :σ_add)

# ╔═╡ 1d5c0f72-7b42-11eb-210e-63e415fdd4bd
plot(p_summary)

# ╔═╡ b8e0b90c-7b42-11eb-3d6d-d1b739381538
plot(chain[:σ_obs])

# ╔═╡ 75440532-7b42-11eb-08ed-9bbf5e20a07f
sum(chain[:is_accept])

# ╔═╡ bb626c20-80b5-11eb-315b-fbba2819d194
m_test = random_walk(Vector{Union{Missing, Float64}}(undef, length(data_short))); # another version of the model, to set Y to missing, in order to generate posterior prediction below

# ╔═╡ 8caa5372-8338-11eb-12e9-c5d42cfb3b33
# Plot posterior X against original data
begin
	chains = MCMCChains.pool_chain(chain) # sometimes chains need to be explicitely combined into one long chain, unclear when necessary
	xs3_tmp = [chains["X[$(t)]"] for t in 1:50] # this could be done with 'get()' easier...
	xs3 = hcat(xs3_tmp...)'   # combine array of arrays into a matrix, ' transposes
	xs_mean = mean.(eachrow(xs3))
	
	plot(xs_mean)
	plot!(log.(data_short))
end

# ╔═╡ 760d9f52-7b45-11eb-3bfb-4d79fb37c2fc
sims = predict(m_test, chains) # use the missing-y model with chain from the trained model to get posterior predictive samples

# ╔═╡ 66a0ace6-87c3-11eb-1bf1-83f1b21f2c15
extrema(get(sims, :y).y[50]) # I'm getting the random walk back, make sure the y is constrained by trained X and not all over the place.

# ╔═╡ 6ff5b072-87c3-11eb-28d2-cd20e305a24d
let
	sigmas = get(chains, [:σ_add, :σ_obs])
	plot(plot(sigmas.σ_add), plot(sigmas.σ_obs))
end

# ╔═╡ 123ee766-87c4-11eb-3be2-6d0c0ccbbf85
summarize(chain[[:σ_add, :σ_obs]])

# ╔═╡ e279bce6-7b5b-11eb-27e2-a7e512ccc42e
	
DataFrame(sims)


# ╔═╡ 5b6b658c-88a9-11eb-18e7-b9896fe33fd1
sims_y = get(MCMCChains.pool_chain(sims), :y)

# ╔═╡ a94bd6dc-88aa-11eb-148d-bbc86bffa254
get_params(MCMCChains.pool_chain(sims)).y

# ╔═╡ 01cb957c-88ab-11eb-0d05-b3547690df63
sims_matrix = hcat(sims_y.y...) # make into matrix form

# ╔═╡ a71f1e30-88a9-11eb-2a03-d9cae959eede
# Intervals for posterior simulated samples
begin
	sims_q10 = [quantile(c, 0.1) for c in eachcol(sims_matrix)] 
	sims_mean = [mean(c) for c in eachcol(sims_matrix)]
	sims_q90 = [quantile(c, 0.9) for c in eachcol(sims_matrix)]
end

# ╔═╡ 7be5c368-7b5f-11eb-1436-5f9e41c67525
begin	
	xs2 = [quantile(DataFrame(chain)[!,"X[$(t)]"], [0.1, 0.5, 0.9]) for t in 1:50]
end

# ╔═╡ e09e66ca-7b5f-11eb-2889-7d32d26af016
# posterior compatibility interval for X
begin
	q10 = [x[1] for x in xs2]
	q50 = [x[2] for x in xs2]
	q90 = [x[3] for x in xs2]
		
	plot(q50, ribbon=(q50-q10, q90-q50), fillalpha=0.2)	
	plot!(sims_mean, ribbon=(sims_mean-sims_q10, sims_q90-sims_mean), fillalpha=0.2) # This was meant to be X + σ_obs, but seems like a process-only random walk instead.., why?
	scatter!(log.(data_short), color=:grey)	
end

# ╔═╡ c93770ba-87c8-11eb-2a63-bb150a0a6996
begin
	# ADVI variational inference is an alternative way to mcmc to get samples
	# https://turing.ml/dev/tutorials/9-variationalinference/
	advi = ADVI(10, 1000)
	q = vi(pred_model, advi);
end

# ╔═╡ 55ee0eee-88a6-11eb-20c5-277b9b8502e5
samples = rand(q, 10000);

# ╔═╡ 121e7e42-87c9-11eb-2588-47eb34519365
begin
	plot(histogram(samples[51,:], ), histogram(samples[52,:]))
   # label="σ_add", label="σ_obs"
end

# ╔═╡ 0ab7a554-87d9-11eb-14d7-f35fbdcb742f
let
  samples_mean = [ mean(x) for x in eachrow(samples[1:50,:])]
	q10 = [ quantile(x, 0.1) for x in eachrow(samples[1:50,:])]
	q90 = [ quantile(x, 0.9) for x in eachrow(samples[1:50,:])]
  plot(samples_mean, ribbon=(samples_mean-q10, q90-samples_mean), fillalpha=0.3)
  plot!(log.(data_short), color=:black) # The shape is right but something's off..
end

# ╔═╡ Cell order:
# ╠═a1582e64-7b2c-11eb-1fee-db9d590b0564
# ╠═32260a78-7b44-11eb-3285-99284e936aac
# ╠═e5a57830-7b2c-11eb-3940-b9936b5a115c
# ╠═f90ca068-7b2c-11eb-266c-fd255604c322
# ╠═fa55548c-7b2c-11eb-02d3-e3d5a289f79e
# ╟─ff034744-7b2c-11eb-212b-53ff285f2069
# ╟─f7304396-7b33-11eb-0f81-a74f2abd2551
# ╠═12ab529c-87c5-11eb-29a2-bb564464bcf1
# ╠═47a5ccba-7b2d-11eb-33ea-2f63b1b42daa
# ╠═7f156b5a-7b2e-11eb-16b8-05c4cda49df0
# ╠═a4bc9064-7b43-11eb-1521-17658b37fcc5
# ╠═d0af2f52-87d9-11eb-21c7-bfe1a786394e
# ╠═24a7e008-7b2e-11eb-0a55-a9dba9549591
# ╠═ab1be9c4-87c0-11eb-15f9-330576f3bdd9
# ╠═185983c2-833e-11eb-0561-c3e0b9f2568f
# ╠═1b6a29e2-80b5-11eb-2796-27a01e45ef1b
# ╠═54e561e6-80b5-11eb-0c7d-e11f8eee62b1
# ╠═edd5d0d4-7b42-11eb-1ffa-d5f7ede144c5
# ╠═d255f1f0-7b41-11eb-3a4a-0f582290c994
# ╠═f6b3c8fc-8590-11eb-174d-81f3f378b649
# ╠═1d5c0f72-7b42-11eb-210e-63e415fdd4bd
# ╠═b8e0b90c-7b42-11eb-3d6d-d1b739381538
# ╠═75440532-7b42-11eb-08ed-9bbf5e20a07f
# ╠═bb626c20-80b5-11eb-315b-fbba2819d194
# ╠═760d9f52-7b45-11eb-3bfb-4d79fb37c2fc
# ╠═66a0ace6-87c3-11eb-1bf1-83f1b21f2c15
# ╠═8caa5372-8338-11eb-12e9-c5d42cfb3b33
# ╠═6ff5b072-87c3-11eb-28d2-cd20e305a24d
# ╠═123ee766-87c4-11eb-3be2-6d0c0ccbbf85
# ╠═e279bce6-7b5b-11eb-27e2-a7e512ccc42e
# ╠═5b6b658c-88a9-11eb-18e7-b9896fe33fd1
# ╠═a94bd6dc-88aa-11eb-148d-bbc86bffa254
# ╠═01cb957c-88ab-11eb-0d05-b3547690df63
# ╠═a71f1e30-88a9-11eb-2a03-d9cae959eede
# ╠═7be5c368-7b5f-11eb-1436-5f9e41c67525
# ╠═e09e66ca-7b5f-11eb-2889-7d32d26af016
# ╠═c93770ba-87c8-11eb-2a63-bb150a0a6996
# ╠═55ee0eee-88a6-11eb-20c5-277b9b8502e5
# ╠═121e7e42-87c9-11eb-2588-47eb34519365
# ╠═0ab7a554-87d9-11eb-14d7-f35fbdcb742f
