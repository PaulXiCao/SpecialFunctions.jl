@testset "airy" begin
    @test_throws AmosException airyai(200im)
    @test_throws AmosException airybi(200)

    for T in [Float16, Float32, Float64,Complex{Float16}, Complex{Float32},Complex{Float64}]
        @test airyai(T(1.8)) ≈ 0.0470362168668458052247
        @test airyaiprime(T(1.8)) ≈ -0.0685247801186109345638
        @test airybi(T(1.8)) ≈ 2.595869356743906290060
        @test airybiprime(T(1.8)) ≈ 2.98554005084659907283
    end
    for T in [Complex{Float16}, Complex{Float32}, Complex{Float64}]
        z = convert(T,1.8 + 1.0im)
        @test airyaix(z) ≈ airyai(z) * exp(2/3 * z * sqrt(z))
        @test airyaiprimex(z) ≈ airyaiprime(z) * exp(2/3 * z * sqrt(z))
        @test airybix(z) ≈ airybi(z) * exp(-abs(real(2/3 * z * sqrt(z))))
        @test airybiprimex(z) ≈ airybiprime(z) * exp(-abs(real(2/3 * z * sqrt(z))))
    end
    @test_throws MethodError airyai(complex(big(1.0)))

    for x = -3:3
        @test airyai(x) ≈ airyai(complex(x))
        @test airyaiprime(x) ≈ airyaiprime(complex(x))
        @test airybi(x) ≈ airybi(complex(x))
        @test airybiprime(x) ≈ airybiprime(complex(x))
        if x >= 0
            @test airyaix(x) ≈ airyaix(complex(x))
            @test airyaiprimex(x) ≈ airyaiprimex(complex(x))
        else
            @test_throws DomainError airyaix(x)
            @test_throws DomainError airyaiprimex(x)
        end
        @test airybix(x) ≈ airybix(complex(x))
        @test airybiprimex(x) ≈ airybiprimex(complex(x))
    end
end
