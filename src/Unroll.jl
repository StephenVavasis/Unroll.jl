module Unroll


copy_and_substitute_tree(e, varname, newtext, mod) = e

copy_and_substitute_tree(e::Symbol, varname, newtext, mod) =
    e == varname ? newtext : e

function copy_and_substitute_tree(e::Expr, varname, newtext, mod)
    e2 = Expr(e.head)
    for subexp in e.args
        push!(e2.args, copy_and_substitute_tree(subexp, varname, newtext, mod))
    end
    if e.head == :if
        newe = e2
        try
            u = Core.eval(mod, e2.args[1])
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
    for k in Core.eval(__module__, expr.args[1].args[2])
        e2 = copy_and_substitute_tree(expr.args[2], varname, k, __module__)
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
    for k in Core.eval(__module__, expr.args[2].args[2])
        e2 = copy_and_substitute_tree(expr.args[1], varname, k, __module__)
        push!(ret.args,e2)
    end
    esc(ret)
end

export @unroll
export @tuplegen

end
