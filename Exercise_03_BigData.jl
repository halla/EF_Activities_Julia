### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 939289d6-6f72-11eb-16d5-b348b52080fe
begin
	using PlutoUI
	using NetCDF     # https://github.com/JuliaGeo/NetCDF.jl
	using NCDatasets # https://github.com/Alexander-Barth/NCDatasets.jl
	using Downloads  # https://github.com/JuliaLang/Downloads.jl
	using CSV, Plots, DataFrames
end

# ╔═╡ 474f6af0-7763-11eb-1f6d-df97793566eb


# ╔═╡ 1d8cfbee-7763-11eb-1286-2714fbdd139d
md"""
## Download
"""

# ╔═╡ 42c9a07c-7763-11eb-069d-c74e7a16deac
begin
	url1 = "https://raw.githubusercontent.com/EcoForecast/EF_Activities/master/data/gflu_data.txt"
	temp_file = Downloads.download(url1) # Download the file to a temporary location	
end

# ╔═╡ f605edf8-7763-11eb-3e4e-9f07a0ff1cc6
df_flu = CSV.File(temp_file, header=11) |> DataFrame # make DataFrame out of CSV parser output

# ╔═╡ f3c467d8-7763-11eb-0cf0-bf59948adfa1
plot(df_flu.Date, df_flu[:,"Boston, MA"]) # Two ways of accessing a single column

# ╔═╡ 292e944c-6f89-11eb-02cf-ff1a12e8cf00
md"""
There are two projects NetCDF and NCDatasets 
* NetCDF is older
  * https://github.com/JuliaGeo/NetCDF.jl
  *  "octave/matlab style interface"
* NCDatasets calls NetCDF
  * https://github.com/Alexander-Barth/NCDatasets.jl

"""

# ╔═╡ 96efea72-774e-11eb-2006-27eb71147628
begin
	# Download nc dataset and store it in the working directory
	nc_filename = "US-PFa-WLEF-TallTowerClean-2012-L0-vFeb2013.nc"
	url2 = "http://co2.aos.wisc.edu/data/cheas/wlef/netcdf/$(nc_filename)"
	Downloads.download(url2, nc_filename)
end

# ╔═╡ 94a7e06c-774e-11eb-0dd0-159a3dae5b7a
md"""
## NetCDF
"""

# ╔═╡ 248dba70-6f8a-11eb-198e-fd129b9ab72c
with_terminal() do
	ncinfo(nc_filename)
end

# ╔═╡ 9b790942-6f89-11eb-2824-e382026be886
x = ncread(nc_filename, "NEE_co2")

# ╔═╡ a2018bc2-6f89-11eb-2e74-5fe0b38520a6
md"""
## NCDatasets
"""

# ╔═╡ 8df5c2be-6f8a-11eb-1ee9-4da11c6df027
ds = Dataset(nc_filename)

# ╔═╡ 94fbb6a4-6f8a-11eb-0321-072fd3fb7ff0
ds["NEE_co2"]

# ╔═╡ 34633028-6f89-11eb-175c-af29f3f6bdfb


# ╔═╡ Cell order:
# ╠═939289d6-6f72-11eb-16d5-b348b52080fe
# ╠═474f6af0-7763-11eb-1f6d-df97793566eb
# ╠═1d8cfbee-7763-11eb-1286-2714fbdd139d
# ╠═42c9a07c-7763-11eb-069d-c74e7a16deac
# ╠═f605edf8-7763-11eb-3e4e-9f07a0ff1cc6
# ╠═f3c467d8-7763-11eb-0cf0-bf59948adfa1
# ╠═292e944c-6f89-11eb-02cf-ff1a12e8cf00
# ╠═96efea72-774e-11eb-2006-27eb71147628
# ╠═94a7e06c-774e-11eb-0dd0-159a3dae5b7a
# ╠═248dba70-6f8a-11eb-198e-fd129b9ab72c
# ╠═9b790942-6f89-11eb-2824-e382026be886
# ╟─a2018bc2-6f89-11eb-2e74-5fe0b38520a6
# ╠═8df5c2be-6f8a-11eb-1ee9-4da11c6df027
# ╠═94fbb6a4-6f8a-11eb-0321-072fd3fb7ff0
# ╠═34633028-6f89-11eb-175c-af29f3f6bdfb
