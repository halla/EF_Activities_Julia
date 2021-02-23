### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 847db912-7453-11eb-2b8a-23a37ad3ae86
using StanSample, Plots

# ╔═╡ 6af9fa38-758d-11eb-0779-d34b07fe0003
md"""
## Stan

This version uses Stan (https://mc-stan.org/ ). Stan.jl is a Julia package that wraps the command-line utility _cmdstan_ . You need to download the source code and build it yourself. 

The Stan documentation (https://mc-stan.org/users/documentation/) is a valuable source for learning probabilisic modeling in general, even if using other tools for the job. 

"""

# ╔═╡ f1c68756-7453-11eb-1ff8-491f911a95fb
ENV["JULIA_CMDSTAN_HOME"]="/home/anttih/progs/cmdstan"

# ╔═╡ 7b9ef1a8-758e-11eb-109d-eb0ee9da9841
# The model is described as a string. Using a separate editor with syntax highlighting 
# might be a good idea for larger models
# see https://mc-stan.org/docs/2_26/stan-users-guide/linear-regression.html

model = "
data { 
 	int<lower=0> N; 
	vector[N] x; 
	vector[N] y;
} 
parameters {
	real alpha;
	real beta;
 	
	real<lower=0> sigma;
} 
model {
    y ~ normal(alpha + beta * x, sigma);
}
";

# priors are not set (defaults to uniform?), except the lower bound 0 for sigma
# y is vectorized. an unvectorized version can also be done using for-loop
#  for (n in 1:N)
#	  y[n] ~ normal(alpha + beta * x[n], sigma);
#
# input matrix can also be used (with or without separate alpha):
# data {
#   ...
#   int<lower=0> K;   // number of predictors
# 	matrix[N, K] x;   // predictor matrix
# }
# parameters {
# 	...
#   vector[K] beta;       // coefficients for predictors
# }
# model {
#   y ~ normal(x * beta, sigma);
# }
# 

# ╔═╡ b3df1910-7590-11eb-06fa-d7ede4683b98
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

# ╔═╡ ba4dc422-7590-11eb-3432-7991ec1c96bd
scatter(x_seq, y_true)

# ╔═╡ c8cf1c4a-7592-11eb-0fe6-1bd8a9451539
length(x_seq)

# ╔═╡ 321b89fc-7592-11eb-377c-395b7349fcdf


# ╔═╡ a7060570-7453-11eb-3e85-8d9280373bfe
sm = SampleModel("example", model);

# ╔═╡ fa161918-7592-11eb-0032-839e3883483e


# ╔═╡ ae6622f0-7453-11eb-3da8-e58c68398f04
data = Dict("N" => length(x_seq), "x" => x_seq, "y" => y_true)

# ╔═╡ f413745c-7592-11eb-2afe-2dcd12cffd68


# ╔═╡ 95df6228-7453-11eb-3d64-1d480170d5db
begin
	rc = stan_sample(sm, data=data);
	
	if success(rc)
	  samples = read_samples(sm);
	end
end

# ╔═╡ 4d1a93cc-7454-11eb-1d8b-673b17cfe679
samples

# ╔═╡ 538abff8-7593-11eb-29ce-2504d7e54139
StanSample.read_summary(sm)

# ╔═╡ Cell order:
# ╠═6af9fa38-758d-11eb-0779-d34b07fe0003
# ╠═847db912-7453-11eb-2b8a-23a37ad3ae86
# ╠═f1c68756-7453-11eb-1ff8-491f911a95fb
# ╠═7b9ef1a8-758e-11eb-109d-eb0ee9da9841
# ╠═b3df1910-7590-11eb-06fa-d7ede4683b98
# ╠═ba4dc422-7590-11eb-3432-7991ec1c96bd
# ╠═c8cf1c4a-7592-11eb-0fe6-1bd8a9451539
# ╠═321b89fc-7592-11eb-377c-395b7349fcdf
# ╠═a7060570-7453-11eb-3e85-8d9280373bfe
# ╠═fa161918-7592-11eb-0032-839e3883483e
# ╠═ae6622f0-7453-11eb-3da8-e58c68398f04
# ╠═f413745c-7592-11eb-2afe-2dcd12cffd68
# ╠═95df6228-7453-11eb-3d64-1d480170d5db
# ╠═4d1a93cc-7454-11eb-1d8b-673b17cfe679
# ╠═538abff8-7593-11eb-29ce-2504d7e54139
