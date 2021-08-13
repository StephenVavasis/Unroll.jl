module test_unroll

using Unroll:@unroll
using Unroll:@tuplegen
using Test:@test

const INNERLOOPBOUND = 2

function tu1_plain(n)
    a = Int[]
    b = Int[]
    for i = 1 : n
        push!(a, i)
        push!(b, 2*i)
    end
    y = 1
    for tr = 1 : 10
        x = 0
        for i = 1 : n - 2
            for j = 1 : 2
                x += a[i] * b[i+j]
            end
        end
        y += x
    end
    y
end

function tu1_handunroll(n)
    a = Int[]
    b = Int[]
    for i = 1 : n
        push!(a, i)
        push!(b, 2*i)
    end
    y = 1
    for tr = 1 : 10
        x = 0
        for i = 1 : n - 2
            x += a[i] * b[i+1]
            x += a[i] * b[i+2]
        end
        y += x
    end
    y
end

function tu1_macrounroll(n)
    a = Int[]
    b = Int[]
    for i = 1 : n
        push!(a, i)
        push!(b, 2*i)
    end
    y = 1
    for tr = 1 : 10
        x = 0
        for i = 1 : n - 2
            @unroll for j = 1 : 2
                x += a[i] * b[i+j]
            end
        end
        y += x
    end
    y
end



function tu2_plain(n)
    a = Int[]
    b = Int[]
    for i = 1 : n
        push!(a, i)
        push!(b, 2*i)
    end
    y = 1
    for tr = 1 : 10
        x = 0
        for i = 1 : n - 2
            for j = 1 : 2
                for k = 1 : 2
                    x += a[i+k] * b[i+j]
                end
            end
        end
        y += x
    end
    y
end

function tu2_handunroll(n)
    a = Int[]
    b = Int[]
    for i = 1 : n
        push!(a, i)
        push!(b, 2*i)
    end
    y = 1
    for tr = 1 : 10
        x = 0
        for i = 1 : n - 2
            x += a[i+1] * b[i+1]
            x += a[i+2] * b[i+1]
            x += a[i+1] * b[i+2]
            x += a[i+2] * b[i+2]
        end
        y += x
    end
    y
end

function tu2_macrounroll(n)
    a = Int[]
    b = Int[]
    for i = 1 : n
        push!(a, i)
        push!(b, 2*i)
    end
    y = 1
    for tr = 1 : 10
        x = 0
        for i = 1 : n - 2
            @unroll for j = 1 : 2
                @unroll for k = 1 : 2
                    x += a[i+k] * b[i+j]
                end
            end
        end
        y += x
    end
    y
end


function tu3_plain(n)
    a = Int[]
    b = Int[]
    for i = 1 : n
        push!(a, i)
        push!(b, 2*i)
    end
    y = 1
    for tr = 1 : 10
        x = 0
        for i = 1 : n - 2
            for j = 1 : 2
                if j == 1
                    x += a[i] * b[i+j]
                else
                    x -= a[i] * b[i+j]
                end
            end
        end
        y += x
    end
    y
end


function tu3_handunroll(n)
    a = Int[]
    b = Int[]
    for i = 1 : n
        push!(a, i)
        push!(b, 2*i)
    end
    y = 1
    for tr = 1 : 10
        x = 0
        for i = 1 : n - 2
            x += a[i] * b[i+1]
            x -= a[i] * b[i+2]
        end
        y += x
    end
    y
end


function tu3_macrounroll(n)
    a = Int[]
    b = Int[]
    for i = 1 : n
        push!(a, i)
        push!(b, 2*i)
    end
    y = 1
    for tr = 1 : 10
        x = 0
        for i = 1 : n - 2
            @unroll for j = 1 : 2
                if j == 1
                    x += a[i] * b[i+j]
                else
                    x -= a[i] * b[i+j]
                end
            end
        end
        y += x
    end
    y
end

const TUPLELENGTH = 3

# function test_tuplegen()
#     v = @tuplegen [(i==2) ? i * 6 : i for i = 1 : TUPLELENGTH]
#     @test isa(v, Tuple{Int,Int,Int})
#     @test v[1] == 1 && v[2] == 12 && v[3] == 3
# end


# test_tuplegen()
println("TIMING TEST FOR SINGLE UNROLL")
println("no unrolling:")
@time y1=tu1_plain(10000000)
println("hand unrolled:")
@time y2=tu1_handunroll(10000000)
println("unrolled by the macro")
@time y3=tu1_macrounroll(10000000)
@test y1==y2 && y2==y3
println("TIMING TEST FOR NESTED UNROLL")
println("no unrolling:")
@time z1=tu2_plain(10000000)
println("hand unrolled:")
@time z2=tu2_handunroll(10000000)
println("unrolled by the macro")
@time z3=tu2_macrounroll(10000000)
@test z1==z2 && z2==z3
println("TIMING TEST FOR IF-ELSE UNROLL")
println("no unrolling:")
@time w1=tu3_plain(10000000)
println("hand unrolled:")
@time w2=tu3_handunroll(10000000)
println("unrolled by the macro")
@time w3=tu3_macrounroll(10000000)
@test w1==w2 && w2==w3

end
