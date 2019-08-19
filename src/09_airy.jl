function _airy(z::Complex{Float64}, id::Int32, kode::Int32)
    ai1, ai2 = Ref{Float64}(), Ref{Float64}()
    ae1, ae2 = Ref{Int32}(), Ref{Int32}()

    ccall((:zairy_,openspecfun), Cvoid,
          (Ref{Float64}, Ref{Float64}, Ref{Int32}, Ref{Int32},
           Ref{Float64}, Ref{Float64}, Ref{Int32}, Ref{Int32}),
           real(z), imag(z), id, kode,
           ai1, ai2, ae1, ae2)

    if ae2[] == 0 || ae2[] == 3 # ignore underflow and less than half machine accuracy loss
        return complex(ai1[], ai2[])
    else
        throw(AmosException(ae2[]))
    end
end

function _biry(z::Complex{Float64}, id::Int32, kode::Int32)
    ai1, ai2 = Ref{Float64}(), Ref{Float64}()
    ae1 = Ref{Int32}()

    ccall((:zbiry_,openspecfun), Cvoid,
          (Ref{Float64}, Ref{Float64}, Ref{Int32}, Ref{Int32},
           Ref{Float64}, Ref{Float64}, Ref{Int32}),
           real(z), imag(z), id, kode,
           ai1, ai2, ae1)

    if ae1[] == 0 || ae1[] == 3 # ignore less than half machine accuracy loss
        return complex(ai1[], ai2[])
    else
        throw(AmosException(ae1[]))
    end
end


"""
    airyai(x)

Airy function of the first kind ``\\operatorname{Ai}(x)``.
"""
function airyai end
airyai(z::Complex{Float64}) = _airy(z, Int32(0), Int32(1))

"""
    airyaiprime(x)

Derivative of the Airy function of the first kind ``\\operatorname{Ai}'(x)``.
"""
function airyaiprime end
airyaiprime(z::Complex{Float64}) =  _airy(z, Int32(1), Int32(1))

"""
    airybi(x)

Airy function of the second kind ``\\operatorname{Bi}(x)``.
"""
function airybi end
airybi(z::Complex{Float64}) = _biry(z, Int32(0), Int32(1))

"""
    airybiprime(x)

Derivative of the Airy function of the second kind ``\\operatorname{Bi}'(x)``.
"""
function airybiprime end
airybiprime(z::Complex{Float64}) = _biry(z, Int32(1), Int32(1))

"""
    airyaix(x)

Scaled Airy function of the first kind ``\\operatorname{Ai}(x) e^{\\frac{2}{3} x
\\sqrt{x}}``.  Throws `DomainError` for negative `Real` arguments.
"""
function airyaix end
airyaix(z::Complex{Float64}) = _airy(z, Int32(0), Int32(2))

"""
    airyaiprimex(x)

Scaled derivative of the Airy function of the first kind ``\\operatorname{Ai}'(x)
e^{\\frac{2}{3} x \\sqrt{x}}``.  Throws `DomainError` for negative `Real` arguments.
"""
function airyaiprimex end
airyaiprimex(z::Complex{Float64}) =  _airy(z, Int32(1), Int32(2))

"""
    airybix(x)

Scaled Airy function of the second kind ``\\operatorname{Bi}(x) e^{- \\left| \\operatorname{Re} \\left( \\frac{2}{3} x \\sqrt{x} \\right) \\right|}``.
"""
function airybix end
airybix(z::Complex{Float64}) = _biry(z, Int32(0), Int32(2))

"""
    airybiprimex(x)

Scaled derivative of the Airy function of the second kind ``\\operatorname{Bi}'(x) e^{- \\left| \\operatorname{Re} \\left( \\frac{2}{3} x \\sqrt{x} \\right) \\right|}``.
"""
function airybiprimex end
airybiprimex(z::Complex{Float64}) = _biry(z, Int32(1), Int32(2))

for afn in (:airyai, :airyaiprime, :airybi, :airybiprime,
            :airyaix, :airyaiprimex, :airybix, :airybiprimex)
    @eval begin
        $afn(z::Complex) = $afn(float(z))
        $afn(z::Complex{Float16}) = Complex{Float16}($afn(Complex{Float32}(z)))
        $afn(z::Complex{Float32}) = Complex{Float32}($afn(Complex{Float64}(z)))
        $afn(z::Complex{<:AbstractFloat}) = throw(MethodError($afn,(z,)))
    end
    if afn in (:airyaix, :airyaiprimex)
        @eval $afn(x::Real) = x < 0 ? throw(DomainError(x, "`x` must be nonnegative.")) : real($afn(complex(float(x))))
    else
        @eval $afn(x::Real) = real($afn(complex(float(x))))
    end
end

function airyai(x::BigFloat)
    z = BigFloat()
    ccall((:mpfr_ai, :libmpfr), Int32, (Ref{BigFloat}, Ref{BigFloat}, Int32), z, x, ROUNDING_MODE[])
    return z
end
