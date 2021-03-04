### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ f77b7f12-74f8-11eb-270a-c95378a81b40
using PlutoUI # for with_terminal() function to display introspection results

# ╔═╡ d4708242-74f8-11eb-02cb-452ae016ada2


# ╔═╡ 57c9bc8a-66e4-11eb-194a-f1e5663526a6
md"""
This is a Pluto notebook, see https://github.com/fonsp/Pluto.jl 

You should be able to run this code in other environments, since this is also a valid Julia source file.

Shift+Enter in a cell to execute it (or click the play-button in bottom-right corner of the cell).

Show/hide code by clicking the eye-icon to the left of a cell.

The notebook is _reactive_, meaning if you change variables in one cell, all following cells using that variable are updated automatically. 

Pluto.jl is still quite young at the time of writing this (0.12.20), some glitches are to be expected. Especially, it might slow down and eventually hang after some time. Just restart it and you are good to go again.

"""

# ╔═╡ 938503d8-6f81-11eb-37aa-378d4c129802
(
3 + 12,  		  ## addition
5 - pi,			  ## subtraction
2 * 8,			    ## multiplication
14 / 5,			  ## division
14 ÷ 5,		  ## integer division, write \div <tab> to get this symbol
14 % 5		    ## modulus (a.k.a. remainder)
)				## parentheses, just to wrap the results in a single tuple so Pluto can display it properly

#  Press Shift+Enter when cell is selected to run it again, or click the play-button in the bottom-right corner of the cell. You can see the output above the cell after it has been run. There's a small triangle that expands the output, helps eg with large array output.

# ╔═╡ 8ebb1632-6f82-11eb-0b05-5300d45c11fb
begin
	print(1)
	print(2)
end

# ╔═╡ 86862b5c-6f82-11eb-0860-b9bc850ea303
sqrt(25)

# ╔═╡ 916edf28-6f82-11eb-0064-5b4113ea366e
factorial(10)

# ╔═╡ aef0d3f0-6f82-11eb-11e1-05fde920dbe1
# Exponentials and logarithms

(
exp(10),   ## exponential function exp(1) == 2.718282... (Euler's number, e)
log(10),   ## natural logarithm (i.e. ln)
log10(10), ## log base 10
log2(10),  ## log base 2
)

# ╔═╡ afb50b7c-6f82-11eb-2dda-abe8fa0ab93e
# Trigonometry

(
sin(pi/2),           ## sine
cos(pi),             ## cosine
tan(pi/4),           ## tangent
asin(0.5),           ## arc-sine
acos(0.5),           ## arc-cosine
atan(1)*180/pi,      ## arc-tangent
atan(-1,-1)*180/pi ## arc-tangent (alternate, two-argument version)
)

# ╔═╡ 65e4083c-6f83-11eb-342c-992508c27a21
# Named arguments

# Julia doesn't seem to have similar support for named arguments as R. There are explicitly declared keyword arguments, but you need to use positional arguments otherwise, eg: atan(-1,1) works but atan(y=-1, x=1) does not.

# ╔═╡ 80c2b0c6-6f84-11eb-2eef-ede8071ba553
# Getting help with ?atan works in command line (REPL). In Pluto there is the 'live docs' section in the bottom-right corner. Click it open and click on a function name you want more info on.

# Auto-complete works by begintyping..<tab>


# ╔═╡ 4e2cfa1c-6f85-11eb-041a-e1df99decd03
md"""
## Sequences
"""

# ╔═╡ 8eb9bdd6-6f85-11eb-1323-915391d31353
# The first way generates a vector of ten integer values from 1 to 10 using a :
(
0:10,
typeof(0:10),
range(0, stop = 10, length = 11),
typeof(range(0, stop = 10, length = 11)),
1:0.1:10,
typeof(1:0.1:10),	
)

# ╔═╡ 79fcfe4e-6f85-11eb-0455-ddc2b7115583
# Make into an array
(collect(0:10),
collect(10:0), # empty!
collect(10:-1:1), # decreasing order need explicit negative step size
	)

# ╔═╡ 717f1f76-66e4-11eb-00b3-a737e2133b64
# Repeat scalar n times(fill an array) 
fill(1,10)

# ╔═╡ 1cc682da-7062-11eb-1890-51f352644244
md"""
## Vector (Array) math
"""

# ╔═╡ feef9f1e-6fc4-11eb-08dc-9be35086fb26
# performing an operation on all elements in an Array 
let 
	x = collect(1:10) # make an array
	(
	x .+ 5, # dot is a 'broadcast' operator, applied to each element
	5 * x, # some operations can work without explicit broadcast
	5 .* x, # but works this way too
	x / 5,
	x .- 5 
	)
end

# ╔═╡ 5cf20532-7062-11eb-1875-dbd9e6be7b66
# Performing elementwise (pairwise) operation on two equal-length arrays
# Pay attention to the broadcast operator (.)
let 
	x = collect(1:10) # make an array
	y = collect(10:-1:1) # negative step size needed collect(10:1) won't work
	(
	x,
	y,
	x.*y,
	x-y,  # this works, but using broadcast maybe more consistent, see division below
	x.-y, 
	x./y,
	x/y # note that this is not element-wise operation, see the results above
	)
		
end

# ╔═╡ 0dd90eea-7063-11eb-0a32-6f4f403116d3
# Functions operating on arrays

(
sum(1:10),  	## sum up all values in a vector
sum(1:10),  	## sum up all values in a vector
diff(1:10),		## calculate the differences between adjacent values in a vector 
cumsum(1:10),		## cumulative sum of values in a vector
prod(1:10),		## product of values in a vector
)

# ╔═╡ aa2fa814-7070-11eb-2259-b9b41afbe615
md"""
## Julia Data types
"""

# ╔═╡ dd0b6c28-7070-11eb-0388-6fc21bb1e938
Dict( # Dictionary takes a key-value pair, both key and value can be of any type
 2 => typeof(2),
 12.3 => typeof(12.3),
 'a' => typeof('a'), 
 "a" => typeof("a"),  #double quotes for text strings
# 'ab' => typeof('ab'), # invalid, single quotes only for individual characters
  (true, false) => (typeof(true), typeof(false))
	# Factor TBD, CategoricalArrays.jl ?
)

# ╔═╡ 5cf47b60-6f85-11eb-0dbc-efe2adbf2c44
md"""
## Introspection

You can explore how Julia turns your code into assembly level instructions in a few steps. Some of these seem to require a terminal to work. If there is no output here, look at the terminal you used to launch Pluto server, or try using the REPL to run the commands if there is no output.
"""

# ╔═╡ 91091b94-66e4-11eb-11ef-fffe3f44a97f
# Introspection, click on the resulting filename:linenumber to browse the actual code
@which fill(1,10)

# ╔═╡ 04e53f02-66ea-11eb-06f4-8d04422c9b62
@code_lowered fill(1,10)

# ╔═╡ 1099c55c-66ea-11eb-3353-eb171625f1f0
with_terminal() do
	@code_llvm fill(1,10)
end

# ╔═╡ 24116d06-66ea-11eb-10c6-7f7caecfe673
@code_typed fill(1,10)

# ╔═╡ 2c905988-66ea-11eb-0413-f3982298c8f8
with_terminal() do
	@code_native fill(1,10)
end


# ╔═╡ Cell order:
# ╠═d4708242-74f8-11eb-02cb-452ae016ada2
# ╠═57c9bc8a-66e4-11eb-194a-f1e5663526a6
# ╠═938503d8-6f81-11eb-37aa-378d4c129802
# ╠═8ebb1632-6f82-11eb-0b05-5300d45c11fb
# ╠═86862b5c-6f82-11eb-0860-b9bc850ea303
# ╠═916edf28-6f82-11eb-0064-5b4113ea366e
# ╠═aef0d3f0-6f82-11eb-11e1-05fde920dbe1
# ╠═afb50b7c-6f82-11eb-2dda-abe8fa0ab93e
# ╠═65e4083c-6f83-11eb-342c-992508c27a21
# ╠═80c2b0c6-6f84-11eb-2eef-ede8071ba553
# ╠═4e2cfa1c-6f85-11eb-041a-e1df99decd03
# ╠═8eb9bdd6-6f85-11eb-1323-915391d31353
# ╠═79fcfe4e-6f85-11eb-0455-ddc2b7115583
# ╠═717f1f76-66e4-11eb-00b3-a737e2133b64
# ╠═1cc682da-7062-11eb-1890-51f352644244
# ╠═feef9f1e-6fc4-11eb-08dc-9be35086fb26
# ╠═5cf20532-7062-11eb-1875-dbd9e6be7b66
# ╠═0dd90eea-7063-11eb-0a32-6f4f403116d3
# ╠═aa2fa814-7070-11eb-2259-b9b41afbe615
# ╠═dd0b6c28-7070-11eb-0388-6fc21bb1e938
# ╠═5cf47b60-6f85-11eb-0dbc-efe2adbf2c44
# ╠═f77b7f12-74f8-11eb-270a-c95378a81b40
# ╠═91091b94-66e4-11eb-11ef-fffe3f44a97f
# ╠═04e53f02-66ea-11eb-06f4-8d04422c9b62
# ╠═1099c55c-66ea-11eb-3353-eb171625f1f0
# ╠═24116d06-66ea-11eb-10c6-7f7caecfe673
# ╠═2c905988-66ea-11eb-0413-f3982298c8f8
