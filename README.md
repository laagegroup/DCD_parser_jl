# DCD.jl
A Julia package for reading DCD trajectory files.

This package is in an early stage. It currently supports only DCD files written by Lammps. This package is a copy of the original package: https://github.com/mvondomaros/DCD.jl.git for NAMD.

## Installation

````julia
pkg> add https://gitlab.com/axel.gomez/dcd-lammps.git
````

## Usage

````julia
using DCD

dcd = load_dcd("foo.dcd")

na = natoms(dcd)  # Get the number of atoms.
nf = nframes(dcd) # Get the number of frames.
δt = timestep(dcd)  # Get the time step.
hascell(dcd)  # Check if the DCD file has unit cell information.

for frame in dcd  # Iterate over each frame.
  r = positions(frame)  # Get an array of all current positions with dimensions (3, na).
  c = cell(dcd)  # Get the unit cell vector [$a, b, c, α, β, γ].
  t = elapsedtime(frame)  # Get the simulation time (in fs) of the current frame.
  
  # Do stuff.
end
````

Happy coding!
