module test_unroll

using Unroll.@unroll
const INNERLOOPBOUND = 2

function tu1_plain(n)
    a = Array{Tuple{Int,Int},1}()
    b = Array{Tuple{Int,Int},1}()
    for i = 1 : n
        push!(a, (i,i))
        push!(b, (2*i,2*i))
    end
    y = 1
    for tr = 1 : 10
        x = 0
        for i = 1 : n
            for j = 1 : 2
                x += a[i][j] + b[i][j]
            end
        end
        y += x
    end
    y
end

function tu1_handunroll(n)
    a = Array{Tuple{Int,Int},1}()
    b = Array{Tuple{Int,Int},1}()
    for i = 1 : n
        push!(a, (i,i))
        push!(b, (2*i,2*i))
    end
    y = 1
    for tr = 1 : 10
        x = 0
        for i = 1 : n
            x += a[i][1] + b[i][1]
            x += a[i][2] + b[i][2]
        end
        y += x
    end
    y
end



function tu1_macrounroll(n)
    a = Array{Tuple{Int,Int},1}()
    b = Array{Tuple{Int,Int},1}()
    for i = 1 : n
        push!(a, (i,i))
        push!(b, (2*i,2*i))
    end
    y = 1
    for tr = 1 : 10
        x = 0
        #println(macroexpand(:(@unroll for j = 1 : 2
        #        x += a[i][j] + b[i][j]
        #        end)))
        for i = 1 : n
            @unroll for j = 1 : 2
                x += a[i][j] + b[i][j]
            end
        end
        y += x
    end
    y
end




function tu2_plain(n)
    a = Array{Tuple{Int,Int},1}()
    b = Array{Tuple{Int,Int},1}()
    for i = 1 : n
        push!(a, (i,i))
        push!(b, (2*i,2*i))
    end
    y = 1
    for tr = 1 : 10
        x = 0
        for i = 1 : n
            for j = 1 : INNERLOOPBOUND
                for k = 1 : INNERLOOPBOUND
                    x += a[i][j] + b[i][k]
                end
            end
        end
        y += x
    end
    y
end

function tu2_handunroll(n)
    a = Array{Tuple{Int,Int},1}()
    b = Array{Tuple{Int,Int},1}()
    for i = 1 : n
        push!(a, (i,i))
        push!(b, (2*i,2*i))
    end
    y = 1
    for tr = 1 : 10
        x = 0
        for i = 1 : n
            x += a[i][1] + b[i][1]
            x += a[i][1] + b[i][2]
            x += a[i][2] + b[i][1]
            x += a[i][2] + b[i][2]
        end
        y += x
    end
    y
end


function tu2_macrounroll(n)
    a = Array{Tuple{Int,Int},1}()
    b = Array{Tuple{Int,Int},1}()
    for i = 1 : n
        push!(a, (i,i))
        push!(b, (2*i,2*i))
    end
    y = 1
    for tr = 1 : 10
        x = 0
        for i = 1 : n
           @unroll for j = 1 : INNERLOOPBOUND
                @unroll for k = 1 : INNERLOOPBOUND
                    x += a[i][j] + b[i][k]
                end
            end
         end
        y += x
    end
    y
end


function tu3_plain(n)
    a = Array{Tuple{Int,Int},1}()
    b = Array{Tuple{Int,Int},1}()
    for i = 1 : n
        push!(a, (i,i))
        push!(b, (2*i,2*i))
    end
    y = 1
    for tr = 1 : 10
        x = 0
        for i = 1 : n
            for j = 1 : 2
                if mod(j,2) == 1
                    x += a[i][j] + b[i][j]
                else
                    x += a[i][j] + 2 * b[i][j]
                end
            end
        end
        y += x
    end
    y
end


function tu3_handunroll(n)
    a = Array{Tuple{Int,Int},1}()
    b = Array{Tuple{Int,Int},1}()
    for i = 1 : n
        push!(a, (i,i))
        push!(b, (2*i,2*i))
    end
    y = 1
    for tr = 1 : 10
        x = 0
        for i = 1 : n
            x += a[i][1] + b[i][1]
            x += a[i][2] + 2 * b[i][2]
        end
        y += x
    end
    y
end

function tu3_macrounroll(n)
    a = Array{Tuple{Int,Int},1}()
    b = Array{Tuple{Int,Int},1}()
    for i = 1 : n
        push!(a, (i,i))
        push!(b, (2*i,2*i))
    end
    y = 1
    for tr = 1 : 10
        x = 0
        for i = 1 : n
            @unroll for j = 1 : 2
                if mod(j,2) == 1
                    x += a[i][j] + b[i][j]
                else
                    x += a[i][j] + 2 * b[i][j]
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
