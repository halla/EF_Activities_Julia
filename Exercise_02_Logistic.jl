### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ a5b819e8-66e2-11eb-3cbd-0b9300be5a57
using Plots, PlutoUI, Chain

# ╔═╡ 1cfb762c-66e2-11eb-035c-070db7665d4d
using Distributions



# ╔═╡ 5137e4e6-677f-11eb-1c04-8d5b4d5e12ec
plotly()

# ╔═╡ 046f4e22-679f-11eb-09ce-295a10026d66
html"""
(css-styling here)
<style>
  main {
    max-width: 1000px;
  }
</style>
"""

# ╔═╡ 7e9fad36-66f5-11eb-27d8-dbc162031896
md"""
### Population growth model 

$$N_{t+1} = N_t + rN\left(1-\frac{N}{K}\right)$$
"""

# ╔═╡ 94bc8094-66e1-11eb-3f71-c37b2dcbeb1a
begin
	r_slider = @bind r Slider(0:0.1:3, default=1)        ## intrinsic growth rate
	K_slider = @bind K Slider(1:20, default=10)       ## carrying capacity      
	NT_slider = @bind NT Slider(30:100)       ## number of time steps to simulate	
	@bind n0  Slider(.1:.9)       ## initial population size
	md"""**Population growth parameters**
	
	Growth rate r: $(r_slider)

	Carrying capacity K: $(K_slider)"""
end

# ╔═╡ d85e5a94-66f4-11eb-3d8a-57745daba96e
time = 1:NT

# ╔═╡ 0ebc5e46-66e2-11eb-121e-312e171a4b94
begin
	n = fill(n0,NT)    ## vector to store results
	for t in 2:NT 
	  n[t] = n[t-1] + r*n[t-1]*(1-n[t-1]/K)
	end
end

# ╔═╡ 222069f0-66e2-11eb-3b62-595fcb638423
plot(time,n,ylim=(0,12),linewidth=3,titlefontsize=12,type=:line,
     xlab="Time",ylab="Population Size", title="Growth rate r: $(r)  Carrying capacity K: $(K)")

# ╔═╡ 16369d76-67b4-11eb-309a-5ffbc730bbaa
md"""
# Probability disributions in Julia

Distributions.jl package 


Distribution   | Julia name | Parameters
------------   | ------ | ----------
beta           | Beta   | shape1, shape2
Binomial       | Binomial  | size, prob
Cauchy         | Cauchy | location, scale
chi-squared    | Chisq  | df
exponential    | Exponential    | rate
F              | FDist  | df1, df2
gamma          | Gamma  | shape, scale
geometric      | Geometric   | prob
hypergeometric | Hypergeometric  | m, n, k
log-normal     | LogNormal  | meanlog, sdlog
logistic       | Logistic  | location, scale
Negative binomial | NegativeBinomial | size, prob
Normal        | Normal    | mean, sd
Poisson       | Poisson    | lambda
Student's t   | TDist       | df
uniform       | Uniform    | min, max
Weibull       | Weibull | shape, scale
Wilcoxon      | ?  | ?

Chisq, Fdist and Students T have non-central versions NoncentralChisq, NoncentralF, NoncentralT respectively, that take an additional noncentrality parameter. 

Basic usage:

```
rand(Normal(mu, sigma), n) - get n random samples from normal distribution with mean mu and standard deviation sigma
pdf(Normal(mu, sigma), x) - probability density function
cdf(Normal(mu, sigma), x) - cumulative distribution function 
quantile(Normal(mu, sigma), p)  # quantile, tail-probability, inverse of pdf
```

or using the chain operator for readability when combining steps:

```
Normal(mu, sigma) |>
	x -> truncated(x,0,Inf) |>  # drop negative part of the distribution
	x -> rand(x, n)

```

or using the @chain _macro_ from Chain.jl library:

```
using Chain
@chain Normal(mu, sigma) begin
	truncated(0,Inf)  # passes the result as first argument by default
	rand(n)
	filter(x -> x < 1, _) # keep values < 1, use underscore _ to pass as non-first argument
end
```



See https://juliastats.org/Distributions.jl/stable/ for more details.
"""

# ╔═╡ f10679d2-67ad-11eb-0e95-1554d62a7bd8
md"""

## Probability density

"""

# ╔═╡ 15269d48-66e2-11eb-0a70-7fb1c1d92155
begin
	begin
		x = -5:0.1:5
		
		plot(x,pdf(Normal(), x), color=:black)
		vline!([0], color=:black)				          	## add a line to indicate the mean (“v” is for “vertical”)
		plot!(x,pdf(Normal(2), x),color=2)			## try changing the mean (“col” sets the color)
		vline!([2], color=2)
		plot!(x,pdf(Normal(-1,2), x),color=3)	## try changing the mean and standard dev
		vline!([-1],color=3)
	end
end

# ╔═╡ c1394c9e-679d-11eb-1110-cb1a0c5f09c8
begin
	mu_slider = @bind μ Slider(-2:0.1:2, default=1)        ## intrinsic growth rate
	sigma_slider = @bind σ Slider(1:0.1:2, default=1)       ## carrying capacity      
	
	md"""**Normal distribution parameters**
	
	Mean μ: $(mu_slider)

	Standard deviation σ: $(sigma_slider)"""
end

# ╔═╡ 1d053216-6c64-11eb-3f5d-7315b8b8f382
	
	@chain Normal(μ, σ) begin
		truncated(0,Inf)  # passes the result as first argument by default
		rand(10)
		filter(x -> x < 1, _) # use underscore _ to pass as non-first argument
	end


# ╔═╡ af2b7b60-679f-11eb-229a-95caa3d6efc6
begin	
	plot(x,pdf(Normal(μ,σ), x),color=:grey, xlim=extrema(x), ylim=(0,1))	## try changing the mean and standard dev
	vline!([μ],color=:grey)
end

# ╔═╡ 13c016de-67a1-11eb-358b-3b6bcdff124d





md"""

## Probability density

"""






# ╔═╡ 1d624718-67ae-11eb-2e9a-5761931614b2
begin
	p = 0:0.01:1
	plot(p,quantile(Normal(), p), color=:black, ylim=extrema(x), label="N(0,1)", legend=:topleft) # ylim sets the y-axis range	
	# extrema returns the min/max as a 2-element vector
	hline!([0], color=:black, label=false)						# “h” for “horizontal”
	plot!(p,quantile(Normal(2,1), p),color=2, label="N(2,1)")
	hline!([2],color=2, label=false)

	plot!(p,quantile(Normal(-1,2), p),color=3, label="N(-1,2)")
	
	hline!([-1],color=3, label=false)
end

# ╔═╡ 19893c48-67b1-11eb-3a39-af914cc91194
let
	n = [10,100,1000,10000]	# sequence of sample sizes
	plots = [ plot(xlim=extrema(x), legend=false) for _ in n ]
	for i in 1:4			# loop over these sample sizes
	  plot!(plots[i], rand(Normal(), n[i]),main=n[i],normalize=true,bins=40, seriestype=:histogram, title="$(n[i])")  
	  #here bins defines number of bins in the histogram
	  plot!(plots[i], x, pdf(Normal(), x),color=2)
	end
	title = plot(title = "Sampling the normal distribution", grid = false, showaxis = false, bottom_margin = -5Plots.px)
	plot(title, plots..., layout = @layout([A{0.01h}; [B C; D E]])) # plot_title not implemented, workaround
end

# ╔═╡ 6692342c-6c5c-11eb-37a0-e30a0adf0575
md"""
#### Jensen's inequality
* transformation of summary statistics != summary stats of transformation
* distribution as a whole can be transformed
"""

# ╔═╡ 819a4716-67b1-11eb-1888-254a14f6103d
let
	x = rand(Normal(0,1), 10000)
	y = x.^2  # the dot . is a broadcast operator to perform the operation on each element

	p1 = plot(x,title="Original distribution",bins=40,seriestype=:hist)
	vline!(quantile(x,[0.025,0.5,0.975]),linestyle=[:dash,:solid,:dash],linewidth=3,color="orange")
	vline!([mean(x)],color=:red,linewidth=3, linestyle=:dot)

	p2 = plot(y,title="Transformed distribution",bins=40, seriestype=:hist)
	vline!(quantile(y,[0.025,0.5,0.975]),linestyle=[:dash,:solid,:dash],linewidth=3,color="orange")
	vline!([mean(y)],color=:red,linewidth=3,linestyle=:dot)
	plot(p1, p2, legend=false, size=(1000,300))
end

# ╔═╡ 5593e304-6c5d-11eb-0d57-9d518d20f675
md"""
#### Parameter error and Monte carlo simulation
Columns are timesteps, rows are monte carlo rounds
"""

# ╔═╡ 819a2c96-67bd-11eb-2f2c-5733a06e1af3
begin
	NE = 1000      ## Ensemble size
	n_sims = zeros((NE,NT))   # storage for all simulations
	
	let
		n = n_sims
		r    = 1.0     ## make sure to return r to it's original value
		r_sd = 0.2     ## standard deviation on r
		K_sd = 1.0     ## standard deviation on K
		

		
		n[:,1] .= n0 # set first column (time step 1) to initial state
		rE = rand(Normal(r,r_sd), NE)  # sample of r
		KE = rand(Normal(K,K_sd), NE)  # sample of K
		for i in 1:NE        # loop over ensemble members
		  for t in 2:NT      # for each ensemble member, simulate throught time
			n[i,t] = max(0,n[i,t-1] + rE[i]*n[i,t-1]*(1-n[i,t-1]/KE[i]))
			end
		end
		n
	end
end

# ╔═╡ 7b658510-6c5d-11eb-32cb-f501472e1d2d
md"""
Mean and 99.95% interval
"""

# ╔═╡ 3eac87f2-67be-11eb-3110-1bd6c32b4098
n_stats = mapslices( n_sims, dims=1) do x
	quantile(x, [0.025, 0.5, 0.975])
end


# ╔═╡ 2482b736-67c1-11eb-3d3d-b3e08f457ad6
begin
	upper = n_stats[3,:] - n_stats[2,:]
	lower = n_stats[2,:] - n_stats[1,:]            
	plot([n_stats[2,:] n_stats[2,:]],                  # apply shade to each subplot
		
	         #shade_xlims,             # xlims for shade
	         #[0,0],                   # dummy y coordinates
	         ribbon = (lower, upper), # apply ylims
	         fillalpha = 0.1,         # set transparency
	         fillcolor=:gray,         # set shade color
			 color=:orange,
	         label = "")
	
end

# ╔═╡ 732519ec-67c1-11eb-0b67-1990a8163be7
zip(n_stats[1,:], n_stats[1,:])

# ╔═╡ 0e9a55c4-67c3-11eb-2491-27a2d21dfd79


# ╔═╡ Cell order:
# ╠═a5b819e8-66e2-11eb-3cbd-0b9300be5a57
# ╠═5137e4e6-677f-11eb-1c04-8d5b4d5e12ec
# ╟─046f4e22-679f-11eb-09ce-295a10026d66
# ╟─7e9fad36-66f5-11eb-27d8-dbc162031896
# ╟─94bc8094-66e1-11eb-3f71-c37b2dcbeb1a
# ╟─d85e5a94-66f4-11eb-3d8a-57745daba96e
# ╠═0ebc5e46-66e2-11eb-121e-312e171a4b94
# ╠═222069f0-66e2-11eb-3b62-595fcb638423
# ╠═1cfb762c-66e2-11eb-035c-070db7665d4d
# ╟─16369d76-67b4-11eb-309a-5ffbc730bbaa
# ╠═1d053216-6c64-11eb-3f5d-7315b8b8f382
# ╟─f10679d2-67ad-11eb-0e95-1554d62a7bd8
# ╠═15269d48-66e2-11eb-0a70-7fb1c1d92155
# ╟─c1394c9e-679d-11eb-1110-cb1a0c5f09c8
# ╠═af2b7b60-679f-11eb-229a-95caa3d6efc6
# ╟─13c016de-67a1-11eb-358b-3b6bcdff124d
# ╠═1d624718-67ae-11eb-2e9a-5761931614b2
# ╠═19893c48-67b1-11eb-3a39-af914cc91194
# ╟─6692342c-6c5c-11eb-37a0-e30a0adf0575
# ╠═819a4716-67b1-11eb-1888-254a14f6103d
# ╟─5593e304-6c5d-11eb-0d57-9d518d20f675
# ╠═819a2c96-67bd-11eb-2f2c-5733a06e1af3
# ╟─7b658510-6c5d-11eb-32cb-f501472e1d2d
# ╠═3eac87f2-67be-11eb-3110-1bd6c32b4098
# ╠═2482b736-67c1-11eb-3d3d-b3e08f457ad6
# ╠═732519ec-67c1-11eb-0b67-1990a8163be7
# ╠═0e9a55c4-67c3-11eb-2491-27a2d21dfd79
