module DCD

using Parameters

export load_dcd, natoms, nframes, timestep, hascell, cell, positions, timepassed


"""
    load_dcd(f::String)

Load a dcd trajectory from file `f`.
"""
function load_dcd(f::String)
    io = open(f)
    load_dcd(io)
end

"""
    load_dcd(io::IO)

Load a dcd trajectory from stream `io`.
"""
function load_dcd(io::IO)
    checkmagic(io)
    FileDCD(io)
end

"""
    checkmagic(io::IO)

Check whether the stream `io` is a valid dcd file by looking at its magic bytes.
"""
function checkmagic(io::IO)
    magic = read(io, 8) 
    magic == UInt8[0x54, 0x00, 0x00, 0x00, 0x43, 0x4f, 0x52, 0x44] || throw("invalid magic bytes")
    seekstart(io)
end

"""
    @with_kw struct FileDCD

Stores information about a dcd trajectory file.
"""
@with_kw struct FileDCD
    io::IO
    natoms::Int64
    nframes::Int64
    δt::Float64
    hascell::Bool
    nbytes_header::Int64
    nbytes_frame::Int64
end

"""
    FileDCD(io::IO)

Construct a [`DCD.FileDCD`](@ref) object from an IO stream `io`.
"""
function FileDCD(io::IO)
    header = Header(io)
    FileDCD(
        io=io,
        natoms=natoms(header),
        nframes=nframes(header),
        δt=timestep(header),
        hascell=hascell(header),
        nbytes_header=nbytes_header(header),
        nbytes_frame=nbytes_frame(header)
        )
end

"""
    iostream(f::FileDCD)

Get the [`IOStream`](@ref) associated with the [`DCD.FileDCD`](@ref) object.
"""
iostream(f::FileDCD) = f.io

"""
    natoms(f::FileDCD)

Get the number of atoms.
"""
natoms(f::FileDCD) = f.natoms

"""
    nframes(f::FileDCD)

Get the number of frames.
"""
nframes(f::FileDCD) = f.nframes

"""
    timestep(f::FileDCD)

Get the time passed between frames.
"""
timestep(f::FileDCD) = f.δt

"""
    hascell(f::FileDCD)

Check if the dcd trajectory file has unit cell information.
"""
hascell(f::FileDCD) = f.hascell

"""
    nbytes_header(f::FileDCD)

Get the number of bytes of the header.
"""
nbytes_header(f::FileDCD) = f.nbytes_header

"""
    nbytes_frame(f::FileDCD)

Get the number of bytes of a single frame.
"""
nbytes_frame(f::FileDCD) = f.nbytes_frame

"""
    Base.eltype(::Type{FileDCD})

[`DCD.FileDCD`](@ref) objects are iterators over [`DCD.FrameDCD`](@ref) objects.
"""
Base.eltype(::Type{FileDCD}) = FrameDCD

function Base.getindex(f::FileDCD, i::Int64)
    1 <= i <= f.nframes || throw(BoundsError(f, i))
    return FrameDCD(f, i)
end
Base.getindex(f::FileDCD, i::Number) = f[convert(Int64, i)]
Base.getindex(f::FileDCD, I) = [f[i] for i in I]
Base.firstindex(f::FileDCD) = 1
Base.lastindex(f::FileDCD) = f.nframes
Base.length(f::FileDCD) = f.nframes

function Base.iterate(f::FileDCD, frame::Int64=1)
    if frame > nframes(f)
        return nothing
    else
        return FrameDCD(f, frame), frame + 1
    end
end


"""
    @with_kw struct Header

Stores information from the dcd trajectory file header.
"""
@with_kw struct Header
    nframes::Int32
    firststep::Int32
    stepincrement::Int32
    laststep::Int32
    δt::Float32
    hascell::Int32
    natoms::Int32
    nbytes::Int64
end

"""
    header(io::IO)

Construct a [`DCD.Header`](@ref) object from an [`IOStream`](@ref).
"""
function Header(io::IO)
    skip(io, 8)
    nframes = read(io, Int32)
    firststep = read(io, Int32)
    stepincrement = read(io, Int32)
    laststep = read(io, Int32)
    skip(io, 20)
    δt = read(io, Float32)
    hascell = read(io, Int32)
    skip(io, 216)
    natoms = read(io, Int32)
    skip(io, 4)
    nbytes = position(io)

    Header(
        nframes=nframes, 
        firststep=firststep, 
        stepincrement=stepincrement, 
        laststep=laststep, 
        δt=δt, 
        hascell=hascell, 
        natoms=natoms,
        nbytes=nbytes
        )
end

"""
    natoms(h::Header)

Get the number of atoms.
"""
natoms(h::Header)::Int64 = h.natoms

"""
    nframes(h::Header)

Get the number of frames.
"""
nframes(h::Header)::Int64 = h.nframes

"""
    timestep(h::Header)

Get the time passed between two subsequent frames.
"""
timestep(h::Header)::Float64 = h.δt * h.stepincrement

"""
    getcell(h::Header)

Check whether the dcd trajectory file has unit cell information.
"""
hascell(h::Header)::Bool = h.hascell

"""
    nbytes_header(h::Header)

Get the number of bytes of the header.
"""
nbytes_header(h::Header)::Int64 = h.nbytes

"""
    nbytes_header(h::Header)

Get the number of bytes of the header.
"""
nbytes_frame(h::Header)::Int64 = hascell(h) ? natoms(h) * 12 + 24 + 56 : natoms(h) * 12 + 24

"""
    seekframe(f::FileDCD, index::Int64)

Move the file's [`IOStream`](@ref) to the position of the indicated frame.
"""
function seekframe(f::FileDCD, index::Int64)
    1 <= index <= f.nframes || throw(BoundsError(f, index))
    pos = nbytes_header(f) + (index - 1) * nbytes_frame(f)
    seek(f.io, pos)
end


"""
    @with_kw struct FrameDCD

Stores simulation time, unit cell information and positions.
"""
@with_kw struct FrameDCD
    time::Float64
    cell::Union{Vector{Float64},Nothing}
    positions::Array{Float64,2}
end

"""
    FrameDCD(f::FileDCD, index::Int64)

Construct a [`DCD.FrameDCD`](@ref) object from a [`DCD.FileDCD`](@ref) `f` with the specified `index`.
"""
function FrameDCD(f::FileDCD, index::Int64)
    seekframe(f, index)
    time = index * timestep(f)
    io = iostream(f)
    if hascell(f)
        skip(io, 4)
        cell = Vector{Float64}(undef, 6)
        read!(io, cell)
        skip(io, 4)
    else
        cell = nothing
    end
    positions = Array{Float64,2}(undef, 3, natoms(f))
    for dim in 1:3
        skip(io, 4)
        for iatom in 1:natoms(f)
            positions[dim, iatom] = read(io, Float32)
        end
        skip(io, 4)
    end

    FrameDCD(time=time, cell=cell, positions=positions)
end

"""
    timepassed(f::FrameDCD)

Get the simulation time that has passed since the beginning of the simulation.
"""
timepassed(f::FrameDCD) = f.time

"""
    positions(f::FrameDCD)

Get the current positions.
"""
positions(f::FrameDCD) = f.positions

function cell(f::FrameDCD)
    cell = zeros(6)
    cell[1] = f.cell[1]
    cell[2] = f.cell[3]
    cell[3] = f.cell[6]
    cell[4] = 90.0 - asind(f.cell[5])
    cell[5]  = 90.0 - asind(f.cell[4])
    cell[6] = 90.0 - asind(f.cell[2])
    cell
end

end
