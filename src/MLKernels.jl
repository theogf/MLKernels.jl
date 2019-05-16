#===================================================================================================
  Kernel Kernels Module
===================================================================================================#

module MLKernels

import Base: convert, eltype, print, show, string, ==, *, /, +, -, ^, exp, tanh

export

    # Memory
    Orientation,

    # Kernel Functions
    Kernel,
        MercerKernel,
            AbstractExponentialKernel,
                ExponentialKernel,
                LaplacianKernel,
                SquaredExponentialKernel,
                GaussianKernel,
                RadialBasisKernel,
                GammaExponentialKernel,
            AbstractRationalQuadraticKernel,
                RationalQuadraticKernel,
                GammaRationalQuadraticKernel,
            MaternKernel,
            LinearKernel,
            PolynomialKernel,
            ExponentiatedKernel,
            PeriodicKernel,
        NegativeDefiniteKernel,
            PowerKernel,
            LogKernel,
        SigmoidKernel,

    # Kernel Function Properties
    ismercer,
    isnegdef,
    isstationary,
    isisotropic,

    # Kernel Matrix
    kernel,
    kernelmatrix,
    kernelmatrix!,
    centerkernelmatrix!,
    centerkernelmatrix,

    # Kernel Approximation
    NystromFact,
    nystrom


using SpecialFunctions: besselk, gamma
using Distances

import LinearAlgebra
import Statistics
##
@doc raw"""
    Orientation

Union of the two `Val` types representing the data matrix orientations:

  1. `Val{:row}` identifies when observation vector corresponds to a row of the data matrix
  2. `Val{:col}` identifies when each observation vector corresponds to a column of the data
     matrix
"""
const Orientation = Union{Val{:row}, Val{:col}}

@inline dim(::Val{:row}) = 1
@inline dim(::Val{:col}) = 2

abstract type Kernel{T<:Real} end

include("utils.jl")
include("distancefunctions/scalarproduct.jl")

# include("basefunctions.jl")
# include("basematrix.jl")

include("kernelfunctions.jl")
include("kernelmatrix.jl")
include("nystrom.jl")

include("deprecated.jl")

end # MLKernels
