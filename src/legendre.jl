function legendreP(n::Integer, x::Real)
    if n < 0
        throw(DomainError(n, "must be non-negative"))
    end
    if x < -1 || x > 1
        throw(DomainError(x, "must be in the range [-1,1]"))
    end

    legendreP_bonnet(n, x)
end

function legendreP_bonnet(n::Integer, x::Real)
    if n == 0
        return 1
    elseif n == 1
        return x
    else
        return  ((2*n-1)/n) * x * legendreP_bonnet(n-1, x) -
                ((n-1)/n)       * legendreP_bonnet(n-2, x)
    end
end
