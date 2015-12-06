Bits = {}

function Bits.read(bits, n)
    n = n or #bits
    local v, m = bits[n], 1
    for i=n-1,1,-1 do
        m = m * 2
        v = v + bits[i] * m
    end
    return v
end

function Bits.write(v, bits, n)
    n = n or #bits
    local q, r = v, 0
    for i=n,1,-1 do
        q,r = q // 2, q % 2
        bits[i] = r
    end
    if q >= 1 then
        return true  -- overflow
    end
    return nil
end
