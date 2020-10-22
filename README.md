# DCD.jl
A Julia package for reading DCD trajectory files.

This package is in an early stage. It currently supports only DCD files written by NAMD. If you are interested in using this package for other DCD flavors, please let me know by opening an issue!

## Installation

````julia
pkg> add https://github.com/mvondomaros/DCD.jl.git
````

## Usage

````julia
using DCD

dcd = load_dcd("foo.dcd")

na = natoms(dcd)  # Get the number of atoms.
nf = nframes(dcd) # Get the number of frames.
timestep(dcd)  # Get the time step.
hascell(dcd)  # Check if the DCD file has unit cell information.

for frame in dcd  # Iterate over each frame.
  positions(frame)  # Get an array of all current positions with dimensions (3, na).
  cell(dcd)  # Get the unit cell vector [$a, b, c, α, β, γ].
  elapsedtime(frame)  # Get the simulation time (in fs) of the current frame.
end
````

Happy coding!
