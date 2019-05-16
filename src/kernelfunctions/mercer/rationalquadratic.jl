# Abstract Rational-Quadratic Kernel =======================================================
abstract type AbstractRationalQuadraticKernel{T<:Real} <: MercerKernel{T} end

# @inline basefunction(::AbstractRationalQuadraticKernel) = SquaredEuclidean()


# Rational-Quadratic Kernel ================================================================
@doc raw"""
    RationalQuadraticKernel([α [,β]])

The rational quadratic kernel is an isotropic Mercer kernel given by the formula:

```
    κ(x,y) = (1 + α‖x-y‖²)⁻ᵝ   α > 0, β > 0
```
where `α` is a scaling parameter and `β` is a shape parameter. The rational quadratic
kernel is a special of the more general gamma-rational-quadratic kernel (see
[`GammaRationalQuadraticKernel`](@ref)) with `γ = 1`.

# Examples

```jldoctest; setup = :(using MLKernels)
julia> RationalQuadraticKernel()
RationalQuadraticKernel{Float64}(1.0,1.0)

julia> RationalQuadraticKernel(2.0f0)
RationalQuadraticKernel{Float32}(2.0,1.0)

julia> RationalQuadraticKernel(2.0f0, 2.0)
RationalQuadraticKernel{Float64}(2.0,2.0)
```
"""
struct RationalQuadraticKernel{T<:Real,A} <: AbstractRationalQuadraticKernel{T}
    α::A
    β::T
    metric::SemiMetric
    function RationalQuadraticKernel{T}(
            α::A=T(1),
            β::Real=T(1)
        ) where {A<:Union{Real,AbstractVector{<:Real}},T<:Real}
        @check_args(RationalQuadraticKernel, α, all(α .> zero(T)), "α > 0")
        @check_args(RationalQuadraticKernel, β, β > zero(T), "β > 0")
        if A <:Real
            new{T,A}(α,β,SqEuclidean())
        else
            new{T,A}(α,β,WeightedSqEuclidean(α))
        end
    end
end
function RationalQuadraticKernel(
        α::Union{T₁,AbstractVector{T₁}}=1.0,
        β::T₂=T₁(1)
    ) where {T₁<:Real, T₂<:Real}
    RationalQuadraticKernel{promote_float(T₁, T₂)}(α, β)
end

@inline function kappa(κ::RationalQuadraticKernel{T,<:Real}, d²::T) where {T}
    return (one(T) + κ.α*d²)^(-κ.β)
end

@inline function kappa(κ::RationalQuadraticKernel{T}, d²::T) where {T}
    return (one(T) + d²)^(-κ.β)
end

function convert(
        ::Type{K},
        κ::RationalQuadraticKernel
    ) where {K>:RationalQuadraticKernel{T,A} where A} where T
    return RationalQuadraticKernel{T}(T.(κ.α), T(κ.β))
end


# Gamma Rational-Quadratic Kernel ==========================================================
@doc raw"""
    GammaRationalKernel([α [,β [,γ]]])

The gamma-rational-quadratic kernel is a generalization of the rational-quadratic kernel
with an additional shape parameter `γ`:

```
    κ(x,y) = (1 + α‖x-y‖²ᵞ)⁻ᵝ   α > 0, β > 0, γ ∈ (0,1]
```
where ``\alpha`` is a scaling parameter, ``\beta`` is a shape parameter and ``\gamma`` is a
shape parameter of the Euclidean distance.

# Examples

```jldoctest; setup = :(using MLKernels)
julia> GammaRationalQuadraticKernel()
GammaRationalQuadraticKernel{Float64}(1.0,1.0,1.0)

julia> GammaRationalQuadraticKernel(2.0f0)
GammaRationalQuadraticKernel{Float32}(2.0,1.0,1.0)

julia> GammaRationalQuadraticKernel(2.0f0, 2.0f0)
GammaRationalQuadraticKernel{Float32}(2.0,2.0,1.0)

julia> GammaRationalQuadraticKernel(2.0f0, 2.0f0, 0.5f0)
GammaRationalQuadraticKernel{Float32}(2.0,2.0,0.5)
```
"""
struct GammaRationalQuadraticKernel{T<:Real,A} <: AbstractRationalQuadraticKernel{T}
    α::A
    β::T
    γ::T
    metric::SemiMetric
    function GammaRationalQuadraticKernel{T}(
            α::A=T(1),
            β::Real=T(1),
            γ::Real=T(1)
        ) where {A<:Union{Real,AbstractVector{<:Real}},T<:Real}
        @check_args(GammaRationalQuadraticKernel, α, all(α .> zero(T)), "∀ α > 0")
        @check_args(GammaRationalQuadraticKernel, β, β > zero(T), "β > 0")
        @check_args(GammaRationalQuadraticKernel, γ, one(T) >= γ > zero(T), "γ ∈ (0,1]")
        if A <:Real
            new{T,A}(α,β,γ,SqEuclidean())
        else
            new{T,A}(α,β,γ,WeightedSqEuclidean(α.^(-γ)))
        end
    end
end
function GammaRationalQuadraticKernel(
        α::Union{T₁,AbstractVector{T₁}} = 1.0,
        β::T₂ = T₁(1),
        γ::T₃ = one(promote_float(T₁, T₂))
    ) where {T₁<:Real, T₂<:Real, T₃<:Real}
    GammaRationalQuadraticKernel{promote_float(T₁,T₂,T₃)}(α, β, γ)
end

@inline function kappa(κ::GammaRationalQuadraticKernel{T,<:Real}, d²::T) where {T}
    return (one(T) + κ.α*(d²^κ.γ))^(-κ.β)
end

@inline function kappa(κ::GammaRationalQuadraticKernel{T}, d²::T) where {T}
    return (one(T) + (d²^κ.γ))^(-κ.β)
end


function convert(
        ::Type{K},
        κ::GammaRationalQuadraticKernel
    ) where {K>:GammaRationalQuadraticKernel{T,A} where A} where T
    return GammaRationalQuadraticKernel{T}(T.(κ.α), T(κ.β), T(κ.γ))
end
