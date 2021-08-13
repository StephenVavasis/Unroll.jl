module Unroll


copy_and_substitute_tree(e, varname, newtext) = e

copy_and_substitute_tree(e::Symbol, varname, newtext) = 
    e == varname ? newtext : e

function copy_and_substitute_tree(e::Expr, varname, newtext)
    e2 = Expr(e.head)
    for subexp in e.args
        push!(e2.args, copy_and_substitute_tree(subexp, varname, newtext))
    end
    if e.head == :if
        newe = e2
        try
            u = eval(e2.args[1])
            if u == true
                newe = e2.args[2]
            elseif u == false
                if length(e2.args) == 3
                    newe = e2.args[3]
                else
                    newe = :nothing
                end
            end
        catch
        end
        e2 = newe
    end
    e2 
end


macro unroll(expr)
    if expr.head != :for || length(expr.args) != 2 ||
        expr.args[1].head != :(=) || 
        typeof(expr.args[1].args[1]) != Symbol ||
        expr.args[2].head != :block
        error("Expression following unroll macro must be a for-loop as described in the documentation")
    end
    varname = expr.args[1].args[1]
    ret = Expr(:block)
    dump(expr.args[1].args[2])
    for k in eval(expr.args[1].args[2])
        e2 = copy_and_substitute_tree(expr.args[2], varname, k)
        push!(ret.args, e2)
    end
    esc(ret)
end

macro tuplegen(expr)
    if expr.head != :comprehension || length(expr.args) != 2 ||
        expr.args[2].head != :(=) ||
        typeof(expr.args[2].args[1]) != Symbol
        error("Expression following tuplegen macro must be a comprehension as described in the documentation")
    end
    varname = expr.args[2].args[1]
    ret = Expr(:tuple)
    for k in eval(expr.args[2].args[2])
        e2 = copy_and_substitute_tree(expr.args[1], varname, k)
        push!(ret.args,e2)
    end
    esc(ret)
end

export @unroll
export @tuplegen

end
