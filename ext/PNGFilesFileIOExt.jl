module PNGFilesFileIOExt

using PNGFiles
using FileIO: File, Stream, DataFormat, stream

# `PNGFiles.load` already returns the canonical PNG result (an `Array` for most
# images and an `IndirectArray` for paletted ones), so no extra canonicalization
# is needed here — we simply forward to it.
function PNGFiles.fileio_load(f::File{DataFormat{:PNG}}; kwargs...)
    return PNGFiles.load(f.filename; kwargs...)
end

function PNGFiles.fileio_load(s::Stream{DataFormat{:PNG}}; kwargs...)
    return PNGFiles.load(stream(s); kwargs...)
end

function PNGFiles.fileio_save(f::File{DataFormat{:PNG}}, image::S; kwargs...) where {T, S<:Union{AbstractMatrix, AbstractArray{T,3}}}
    return PNGFiles.save(f.filename, image; kwargs...)
end

function PNGFiles.fileio_save(s::Stream{DataFormat{:PNG}}, image::S; permute_horizontal=false, mapi=identity, kwargs...) where {T, S<:Union{AbstractMatrix, AbstractArray{T,3}}}
    imgout = map(mapi, image)
    if permute_horizontal
        perm = ndims(imgout) == 2 ? (2, 1) : ndims(imgout) == 3 ? (2, 1, 3) : error("$(ndims(imgout)) dims array is not supported")
        return PNGFiles.save(stream(s), PermutedDimsArray(imgout, perm); kwargs...)
    else
        return PNGFiles.save(stream(s), imgout; kwargs...)
    end
end

end # module
