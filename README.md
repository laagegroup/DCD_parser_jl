<div id="top"></div>

<!-- PROJECT SHIELDS -->

[![GNU AGPL v3.0 License][license-shield]][license-url] 
![VERSION](https://img.shields.io/badge/version-0.2.2-blue)

<!-- TABLE OF CONTENTS -->

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about">DCD.jl</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation (with set-up ssh keys)</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#acknowledgments">License and acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
<div id="about"></div>

## DCD.jl

A Julia package for reading DCD trajectory files.

This package currently supports only DCD files written by Lammps.

<p align="right">(<a href="#top">back to top</a>)</p>

<div id="getting-started"></div>

## Getting Started

<div id="prerequisites"></div>

### Prerequisites

This package is a Julia parser for DCD files written by Lammps. It needs Julia 1.5 or above.

<div id="installation"></div>

### Installation (with set-up ssh keys)

Adding private packages to Julia requires a password-less access (see the [manual in this organization for setup](https://github.com/laagegroup/0_HowTo/blob/main/Github_beginner_guide.md#setup-a-password-less-access-over-ssh))

````julia
pkg> add git@github.com:laagegroup/DCD_parser_jl.git
````

### Installation (with https RECOMMENDED)

You can directly install this parser via https by running (from Julia):
```julia
pkg> add https://github.com/laagegroup/DCD_parser_jl.git
```

<p align="right">(<a href="#top">back to top</a>)</p>

<div id="usage"></div>

## Usage

This package can be used in the Julia REPL or within a Julia script. Here is an example of the main features:

````julia
using DCD

dcd = load_dcd("traj.dcd")

na = natoms(dcd)  # Get the number of atoms.
nf = nframes(dcd) # Get the number of frames.
δt = timestep(dcd)  # Get the time step.
hascell(dcd)  # Check if the DCD file has unit cell information.

for frame in dcd  # Iterate over each frame.
  r = positions(frame)  # Get an array of all current positions with dimensions (3, na).
  c = cell(dcd)  # Get the unit cell vector [$a, b, c, α, β, γ].
  t = elapsedtime(frame)  # Get the simulation time (in fs) of the current frame.

  # Work on the current frame.
end
````
<p align="right">(<a href="#top">back to top</a>)</p>


<div id="acknowledgments"></div>

## License and acknowledgments

This package is a modification of the original package: https://github.com/mvondomaros/DCD.jl.git for NAMD. The original work is submitted to the MIT license `original_MIT_license` in the current repository. This work can be retrieved from the commit tree or on the public Github repository of the original author.

Modifications are distributed under the GNU Affero General Public License v3.0. See `LICENSE` for more information.

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[license-shield]: https://img.shields.io/github/license/laagegroup/DCD_parser_jl.svg?style=for-the-badge
[license-url]: https://github.com/laagegroup/DCD_parser_jl/blob/main/LICENSE
