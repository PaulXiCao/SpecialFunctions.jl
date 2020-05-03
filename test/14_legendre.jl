using Polynomials

@testset "legendre and related functions" begin
    @testset "legendrep" begin
        n_poly  = 6
        c       = zeros(n_poly, n_poly)
        c[1,1]  = 1
        c[2,2]  = 1
        c[3, 1:3] .= [-1,  0,   3               ] / 2
        c[4, 1:4] .= [ 0, -3,   0,   5          ] / 2
        c[5, 1:5] .= [ 3,  0, -30,   0, 35      ] / 8
        c[6, 1:6] .= [ 0, 15,   0, -70,  0, 63  ] / 8

        n_x = 20
        x_arr = range(-2, stop=2, length=n_x)
        for n = 0:n_poly-1
            P = ImmutablePolynomial(c[n+1,:])
            for x in x_arr
                @test legendrep(n, x          ) ≈ P(x)              rtol=1e-14
                @test legendrep(n, BigFloat(x)) ≈ P(x)              rtol=1e-13
                @inferred legendrep(n, x)
                @inferred legendrep(n, BigFloat(x))
            end
        end

        @test_throws DomainError legendrep(-1, 0)

        @test_throws MethodError legendrep(0, Complex(1))
    end

    @testset "assoc legendrep" begin
        n_poly  = 6
        n_x     = 20
        x_arr   = range(-2, stop=2, length=n_x)
        for n = 0:n_poly
            for x in x_arr
                @test legendrep(n, x          ) ≈ legendrep(n, 0, x)        rtol=1e-14
                @test legendrep(n, BigFloat(x)) ≈ legendrep(n, 0, x)        rtol=1e-13
            end
        end

        n_max   = 4
        P       = Array{Function,2}(undef, n_max, n_max)

        P[1, 1] = x -> -sqrt(1-x^2)
        P[2, 1] = x -> -3x * sqrt(1-x^2)
        P[2, 2] = x -> 3 * (1-x^2)
        P[3, 1] = x -> -3//2 * sqrt(1-x^2) * (5x^2-1)
        P[3, 2] = x -> 15x * (1-x^2)
        P[3, 3] = x -> -15 * (1-x^2)^1.5
        P[4, 1] = x -> -5//2 * sqrt(1-x^2) * (7x^3-3x)
        P[4, 2] = x -> 15//2 * (1-x^2) * (7x^2-1)
        P[4, 3] = x -> -105 * x * (1-x^2)^1.5
        P[4, 4] = x -> 105 * (1-x^2)^2

        x_arr   = range(-1, stop=1, length=n_x)
        for n = 1:n_max
            for m = 1:n
                for x in x_arr
                    @test legendrep(n, m, x          ) ≈ P[n,m](x)        rtol=1e-14
                    @test legendrep(n, m, BigFloat(x)) ≈ P[n,m](x)        rtol=1e-14
                    @inferred legendrep(n, m, x          )
                    @inferred legendrep(n, m, BigFloat(x))
                end
            end
        end

        @test_throws DomainError legendrep(-1,  0, 0)       # n too small
        @test_throws DomainError legendrep( 1, -1, 0)       # m too small
        @test_throws DomainError legendrep( 1,  2, 0)       # m too large
        @test_throws DomainError legendrep( 1,  1,  1.1)    # x too high
        @test_throws DomainError legendrep( 1,  1, -1.1)    # x too small

        @test_throws MethodError legendrep(0, 0, Complex(1))
    end

    @testset "legendreq" begin
        q = Array{Function,1}(undef,  6)
        Q0(x) = 0.5 * log((1+x)/(1-x))
        q[1] = Q0

        n_poly  = 5
        c       = zeros(n_poly, n_poly)
        c[1,1]  = -1
        c[2,2]  = -3//2
        c[3, 1:3] .= [  2//3,      0, -5//2                 ]
        c[4, 1:4] .= [     0, 55//24,     0, -35//8         ]
        c[5, 1:5] .= [-8//15,      0, 49//8,      0, -63//8 ]

        for i = 1:n_poly
            P      = ImmutablePolynomial(c[i,:])
            q[i+1] = x -> legendrep(i, x) * Q0(x) + P(x)
        end

        n_x = 20
        x_arr = range(-0.99, stop=0.99, length=n_x)
        for n = 0:n_poly
            for x in x_arr
                @test legendreq(n, x          ) ≈ q[n+1](x)        rtol=1e-14
                @test legendreq(n, BigFloat(x)) ≈ q[n+1](x)        rtol=1e-14
                @inferred Float64 legendreq(n, x          )
                @inferred Float64 legendreq(n, BigFloat(x))
            end
        end

        for n in range(0, stop=3n_poly)
            @test               Inf == legendreq(n,  1)
            @test (-1)^(n+1) *  Inf == legendreq(n, -1)
        end

        @test_throws DomainError legendreq(-1,  0)
        @test_throws DomainError legendreq( 1,  1.1)
        @test_throws DomainError legendreq( 1, -1.1)
        @test_throws DomainError legendreq(-1,  1.1)

        @test_throws MethodError legendreq(0, Complex(1))
    end

    @testset "assoc legendreq" begin
        n_poly  = 6
        n_x     = 20
        x_arr   = range(-1, stop=1, length=n_x)
        for n = 0:n_poly
            for x in x_arr
                @test legendreq(n, x          ) ≈ legendreq(n, 0, x)        rtol=1e-14
                @test legendreq(n, BigFloat(x)) ≈ legendreq(n, 0, x)        rtol=1e-14
            end
        end

        n_max   = 2
        m_max   = 3
        Q       = Array{Function,2}(undef, n_max+1, m_max)

        Q[1, 1] = x -> -(1-x^2)^(-0.5)
        Q[1, 2] = x -> 2x / (1-x^2)
        Q[1, 3] = x -> -(2+6x^2) * (1-x^2)^(-1.5)

        Q[2, 1] = x -> -sqrt(1-x^2) * (0.5*log((1+x)/(1-x)) + x/(1-x^2))
        Q[2, 2] = x -> 2 / (1-x^2)
        Q[2, 3] = x -> -8x * (1-x^2)^(-1.5)

        Q[3, 1] = x -> -sqrt(1-x^2) * (3x/2*log((1+x)/(1-x)) + (3x^2-2)/(1-x^2))
        Q[3, 2] = x -> (1-x^2) * (3/2*log((1+x)/(1-x)) - (3x^3-5x)/(1-x^2)^2)
        Q[3, 3] = x -> -8 * (1-x^2)^(-1.5)

        x_arr   = range(-0.99, stop=0.99, length=n_x)
        for n = 0:n_max
            for m = 1:m_max
                for x in x_arr
                    @test legendreq(n, m, x          ) ≈ Q[n+1,m](x)        rtol=1e-14
                    @test legendreq(n, m, BigFloat(x)) ≈ Q[n+1,m](x)        rtol=1e-14
                    @inferred Float64 legendreq(n, m, x          )
                    @inferred Float64 legendreq(n, m, BigFloat(x))
                end
            end
        end

        @test_throws DomainError legendreq(-1,  0,  0)      # n too small
        @test_throws DomainError legendreq( 1, -1,  0)      # m too small
        @test_throws DomainError legendreq( 0,  0,  1.1)    # x too high
        @test_throws DomainError legendreq( 0,  0, -1.1)    # x too small
        @test_throws DomainError legendreq( 0,  1,  1)      # x too high
        @test_throws DomainError legendreq( 0,  1, -1)      # x too small

        @test_throws MethodError legendreq(0, 0, Complex(1))
    end

    @testset "hermite" begin
        n_poly  = 6
        c       = zeros(n_poly, n_poly)
        c[1,1]  = 1
        c[2,2]  = 2
        c[3, 1:3] .= [-2,   0,   4                ]
        c[4, 1:4] .= [ 0, -12,   0,    8          ]
        c[5, 1:5] .= [12,   0, -48,    0, 16      ]
        c[6, 1:6] .= [ 0, 120,   0, -160,  0, 32  ]

        n_x = 20
        x_arr = range(-2, stop=3, length=n_x)
        for n = 0:n_poly-1
            P = ImmutablePolynomial(c[n+1,:])
            for x in x_arr
                @test hermiteh(n, x          ) ≈ P(x)        rtol=1e-14
                @test hermiteh(n, BigFloat(x)) ≈ P(x)        rtol=1e-14
                @inferred hermiteh(n, x          )
                @inferred hermiteh(n, BigFloat(x))
            end
        end

        @test_throws DomainError hermiteh(-1, 0)

        @test_throws MethodError hermiteh(0, Complex(1))
    end

    @testset "laguerre" begin
        n_poly  = 6
        c       = zeros(n_poly, n_poly)
        c[1,1]  = 1
        c[2, 1:2] .= [  1,   -1                     ]
        c[3, 1:3] .= [  2,   -4,   1                ] / 2
        c[4, 1:4] .= [  6,  -18,   9,   -1          ] / 6
        c[5, 1:5] .= [ 24,  -96,  72,  -16,  1      ] / 24
        c[6, 1:6] .= [120, -600, 600, -200, 25, -1  ] / 120

        n_x = 20
        x_arr = range(0, stop=2, length=n_x)
        for n = 0:n_poly-1
            P = ImmutablePolynomial(c[n+1,:])
            for x in x_arr
                @test laguerrel(n, x          ) ≈ P(x)        rtol=1e-13
                @test laguerrel(n, BigFloat(x)) ≈ P(x)        rtol=1e-13
                @inferred laguerrel(n, x          )
                @inferred laguerrel(n, BigFloat(x))
            end
        end

        @test_throws DomainError laguerrel(-1, 0)
        @test_throws DomainError laguerrel(0, -1)
        @test_throws DomainError laguerrel(-1, -1)

        @test_throws MethodError laguerrel(0, Complex(1))
    end

    @testset "chebyshev 1" begin
        n_poly  = 6
        c       = zeros(n_poly, n_poly)
        c[1,1]  = 1
        c[2, 1:2] .= [ 0,  1                 ]
        c[3, 1:3] .= [-1,  0,  2             ]
        c[4, 1:4] .= [ 0, -3,  0,   4        ]
        c[5, 1:5] .= [ 1,  0, -8,   0, 8     ]
        c[6, 1:6] .= [ 0,  5,  0, -20, 0, 16 ]

        n_x = 20
        x_arr = range(-1, stop=1, length=n_x)
        for n = 0:n_poly-1
            P = ImmutablePolynomial(c[n+1,:])
            for x in x_arr
                @test chebyshevt(n, x          ) ≈ P(x)        rtol=1e-14
                @test chebyshevt(n, BigFloat(x)) ≈ P(x)        rtol=1e-14
                @inferred chebyshevt(n, x          )
                @inferred chebyshevt(n, BigFloat(x))
            end
        end

        @test_throws DomainError chebyshevt(-1, 0)
        @test_throws DomainError chebyshevt(0, 1.1)
        @test_throws DomainError chebyshevt(0, -1.1)
        @test_throws DomainError chebyshevt(-1, 2)

        @test_throws MethodError chebyshevt(0, Complex(1))
    end

    @testset "chebyshev 2" begin
        n_poly  = 6
        c       = zeros(n_poly, n_poly)
        c[1,1]  = 1
        c[2, 1:2] .= [ 0,  2                   ]
        c[3, 1:3] .= [-1,  0,   4              ]
        c[4, 1:4] .= [ 0, -4,   0,   8         ]
        c[5, 1:5] .= [ 1,  0, -12,   0, 16     ]
        c[6, 1:6] .= [ 0,  6,   0, -32,  0, 32 ]

        n_x = 20
        x_arr = range(-1, stop=1, length=n_x)
        for n = 0:n_poly-1
            P = ImmutablePolynomial(c[n+1,:])
            for x in x_arr
                @test chebyshevu(n, x          ) ≈ P(x)        rtol=1e-14
                @test chebyshevu(n, BigFloat(x)) ≈ P(x)        rtol=1e-14
                @inferred chebyshevu(n, x          )
                @inferred chebyshevu(n, BigFloat(x))
            end
        end

        @test_throws DomainError chebyshevu(-1, 0)
        @test_throws DomainError chebyshevu(0, 1.1)
        @test_throws DomainError chebyshevu(0, -1.1)
        @test_throws DomainError chebyshevu(-1, 2)

        @test_throws MethodError chebyshevu(0, Complex(1))
    end
end
