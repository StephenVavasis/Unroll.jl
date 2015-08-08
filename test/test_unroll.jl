module test_unroll

using Unroll.@unroll
const INNERLOOPBOUND = 2

function tu1_plain(n)
    a = Array{Int,1}()
    b = Array{Int,1}()
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
    a = Array{Int,1}()
    b = Array{Int,1}()
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
    a = Array{Int,1}()
    b = Array{Int,1}()
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
    a = Array{Int,1}()
    b = Array{Int,1}()
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
    a = Array{Int,1}()
    b = Array{Int,1}()
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
    a = Array{Int,1}()
    b = Array{Int,1}()
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
    a = Array{Int,1}()
    b = Array{Int,1}()
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
    a = Array{Int,1}()
    b = Array{Int,1}()
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
    a = Array{Int,1}()
    b = Array{Int,1}()
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






println("TIMING TEST FOR SINGLE UNROLL")
println("no unrolling:")
@time tu1_plain(10000000)
println("hand unrolled:")
@time tu1_handunroll(10000000)
println("unrolled by the macro")
@time tu1_macrounroll(10000000)
println("TIMING TEST FOR NESTED UNROLL")
println("no unrolling:")
@time tu2_plain(10000000)
println("hand unrolled:")
@time tu2_handunroll(10000000)
println("unrolled by the macro")
@time tu2_macrounroll(10000000)
println("TIMING TEST FOR IF-THEN UNROLL")
println("no unrolling:")
@time tu3_plain(10000000)
println("hand unrolled:")
@time tu3_handunroll(10000000)
println("unrolled by the macro")
@time tu3_macrounroll(10000000)

end
