### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 70455392-7223-11eb-0975-c9abae197354
begin
	using Turing, Plots # StatsPlots needed to plot chains
	using MCMCChains # For diagnostics
	using PlutoUI 
end

# ╔═╡ a3321caa-7227-11eb-16a2-2b8ed15f2270
html"""
<style>
 main {
    max-width: 1100px;
  }
</style>
"""

# ╔═╡ a6b2ffdc-7224-11eb-1488-e7bcfe296c04
@model function normalMean(mu0, sigma0, sigma, X) 
	mu ~ Normal(mu0,sigma0) # prior on the mean 
	X ~ Normal(mu,sigma) # data model
end

# ╔═╡ 8cbe506c-7225-11eb-052e-4396522bcc3a
# In Turing we use standard deviations (instead of JAGS style precisions)
begin
	sigma = 5  ## prior standard deviation
	X = 42 ## data
	mu0 = 153 ## prior mean
	sigma0 = 13.5
	#S = 1/sigma^2, ## prior precision
	#T = 1/185) ## data precision
end

# ╔═╡ b5e34312-7225-11eb-0478-0961466d0d34
# no need to 'initial conditions' set with hmc?
begin
	begin
		m = normalMean(mu0, sigma0, sigma, X)
		#  Run sampler, collect results
		chn = sample(m, HMC(0.1, 5), 1000, chains=3)
		
		# Summarise results
		describe(chn)
		
	end
end

# ╔═╡ 366c4116-7224-11eb-1365-077771263950
@model function gdemo(x, y)
  s ~ InverseGamma(2, 3)
  m ~ Normal(0, sqrt(s))
  x ~ Normal(m, sqrt(s))
  y ~ Normal(m, sqrt(s))
end

# ╔═╡ 7325e2ea-7226-11eb-2fec-777f253e0cb7
plot(chn)

# ╔═╡ c212ad98-7226-11eb-19e3-271769b85982
begin
	mu_summary = chn[:mu]
	plot(mu_summary, seriestype = :histogram, legend=false)
end

# ╔═╡ 863db886-722a-11eb-16f4-7158d05df68b
gelmandiag(chn)

# ╔═╡ 450ced86-722b-11eb-3911-bdb6123cbbd1
get(describe(chn)[1], :mean)


# ╔═╡ c5bb9aac-72af-11eb-1644-0d2ceaf714f4

	names(describe(chn)[1])


# ╔═╡ a4411902-74ff-11eb-0f51-1dad928ca456
chn

# ╔═╡ 57c78f76-72b2-11eb-2922-157261948f8b
summarize([chn])

# ╔═╡ d15628a2-7460-11eb-13f6-2bccb6cf0187
with_terminal() do
	print(describe(chn))
end

# ╔═╡ d5ec586c-722d-11eb-0686-133f0c0c8eef
describe(chn; sections = :internals)

# ╔═╡ ebf26458-722d-11eb-36e8-3b988d36a049
chn2 = sample(gdemo(1,2), HMC(0.1, 5), 1000)


# ╔═╡ f705ed38-722d-11eb-3135-4bf66d16401f
chn2

# ╔═╡ Cell order:
# ╠═70455392-7223-11eb-0975-c9abae197354
# ╠═a3321caa-7227-11eb-16a2-2b8ed15f2270
# ╠═366c4116-7224-11eb-1365-077771263950
# ╠═a6b2ffdc-7224-11eb-1488-e7bcfe296c04
# ╠═8cbe506c-7225-11eb-052e-4396522bcc3a
# ╠═b5e34312-7225-11eb-0478-0961466d0d34
# ╠═7325e2ea-7226-11eb-2fec-777f253e0cb7
# ╠═c212ad98-7226-11eb-19e3-271769b85982
# ╠═863db886-722a-11eb-16f4-7158d05df68b
# ╠═450ced86-722b-11eb-3911-bdb6123cbbd1
# ╠═c5bb9aac-72af-11eb-1644-0d2ceaf714f4
# ╠═a4411902-74ff-11eb-0f51-1dad928ca456
# ╠═57c78f76-72b2-11eb-2922-157261948f8b
# ╠═d15628a2-7460-11eb-13f6-2bccb6cf0187
# ╠═d5ec586c-722d-11eb-0686-133f0c0c8eef
# ╠═ebf26458-722d-11eb-36e8-3b988d36a049
# ╠═f705ed38-722d-11eb-3135-4bf66d16401f
