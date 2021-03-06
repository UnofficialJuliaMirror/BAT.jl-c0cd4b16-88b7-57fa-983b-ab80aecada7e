# This file is a part of BAT.jl, licensed under the MIT License (MIT).


function _check_rand_compat(s::Sampleable{Multivariate}, A::Union{AbstractVector,AbstractMatrix})
    size(A, 1) == length(s) || throw(DimensionMismatch("Output size inconsistent with sample length."))
    nothing
end



@doc doc"""
    bat_sampler(d::Distribution)

*BAT-internal, not part of stable public API.*

Tries to return a BAT-compatible sampler for Distribution d. A sampler is
BAT-compatible if it supports random number generation using an arbitrary
`AbstractRNG`:

    rand(rng::AbstractRNG, s::SamplerType)
    rand!(rng::AbstractRNG, s::SamplerType, x::AbstractArray)

If no specific method of `bat_sampler` is defined for the type of `d`, it will
default to `sampler(d)`, which may or may not return a BAT-compatible
sampler.
"""
function bat_sampler end

bat_sampler(d::Distribution) = Distributions.sampler(d)



@doc doc"""
    issymmetric_around_origin(d::Distribution)

*BAT-internal, not part of stable public API.*

Returns `true` (resp. `false`) if the Distribution is symmetric (resp.
non-symmetric) around the origin.
"""
function issymmetric_around_origin end


issymmetric_around_origin(d::Normal) = d.μ ≈ 0

issymmetric_around_origin(d::Gamma) = false

issymmetric_around_origin(d::Chisq) = false

issymmetric_around_origin(d::TDist) = true

issymmetric_around_origin(d::MvNormal) = iszero(d.μ)

issymmetric_around_origin(d::Distributions.GenericMvTDist) = d.zeromean


function get_cov end

get_cov(d::Distributions.GenericMvTDist) = d.Σ


function set_cov end

set_cov(d::Distributions.GenericMvTDist{T,Cov}, Σ::Cov) where {T,Cov} =
    Distributions.GenericMvTDist(d.df, deepcopy(d.μ), Σ)

set_cov(d::Distributions.GenericMvTDist{T,Cov}, Σ::AbstractMatrix{<:Real}) where {T,Cov<:PDMat} =
    set_cov(d, PDMat(convert(Matrix{T}, Σ)))
