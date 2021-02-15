# EF_Activities_Julia
Translating the essential parts of R code in https://github.com/EcoForecast/EF_Activities into Julia, identifying relevant libraries etc.

This one uses Pluto notebooks (https://github.com/fonsp/Pluto.jl).

Very much work in progress. 

## Install Julia

Install Julia on your system https://julialang.org/downloads/

On Linux you may also consider something like asdf (https://github.com/asdf-vm/asdf) to manage the Julia installation (and other programming language), especially if you need to have multiple versions installed simultaneously.

On Windows you may want to consider using Windows Subsystem for Linux (WSL) to setup a local Linux environment.

## Project setup

All the Julia library dependencies are declared in the Project.toml file and will be installed when following the steps below. See https://julialang.github.io/Pkg.jl/v1.5/environments/ about environments for more details.

* git clone
* <cd into dir>
* julia   (or julia --project=.)
* ] (to acticate pkg mode)
* (v1.5) pkg> activate .    # activate project in current directory if not yet activated
* (SomeProject) pkg> instantiate     # install dependencies
* <backspace>  (to exit pkg-mode)
* import Pluto
* Pluto.run()
* (Pluto server starts, listens to localhost:1234 by default, navigate there if not opened automatically in browser)
* select notebook to open
* notebook automatically executes everything, might take a while
  



