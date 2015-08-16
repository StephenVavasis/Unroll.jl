================
Unroll macro
================

This package provides the ``unroll`` and ``tuplegen`` macros.
The ``unroll`` macro in Julia unrolls simple for-loops.  For example,
the following code::

   @unroll for i = 1 : 2
      x += a[i]
   end

will macro-expand as::

   x += a[1]
   x += a[2]

For this to be possible, the loop bounds must be known at the time
of macro-expansion.  A common case is that they are literal
constant values as in
the above example.  
The loop bounds may include symbolic constants that are global
within the module::

  const LOOPBOUND = 2
  function myfunct()
     @unroll for i = 1 : LOOPBOUND
        <etc>
     end
  end

The ``unroll`` macro can be nested.  

Finally, the ``unroll`` macro will search for conditionals that
depend on the loop counter and unroll these as well.  For example,
the call::

  @unroll for i = 1 : 4
      if mod(i,2) == 1
          a += b[i]
      else
          a += 2*b[i]
      end
   end

will macro-expand to::

     a += b[1]
     a += 2*b[2]
     a += b[3]
     a += 2*b[4]

------------------
The tuplegen macro
------------------

The ``tuplegen`` macro generates fixed-length tuples using comprehension-like
syntax.  For example::

       v = @tuplegen [(i==2)? i * 6 : i for i = 1 : 4]

macro-expands to::

       v = (1, 2*6, 3, 4)

and therefore generates the tuple ``(1,12,3,4)``.  
Without the ``@tuplegen`` call, this
same statement would generate the array ``[1,12,3,4]``.  It is possible
generate tuples from comprehensions
via the following standard
statement::

       v = tuple([(i==2)? i * 6 : i for i = 1 : 4]...)

but this statement is less efficient because it creates a heap-allocated
array as a temporary.

Here is a more complicated example of ``@tuplegen``.  Suppose 2-by-2
matrices are represented as 2-tuples of 2-tuples, e.g., ``((1,2),(5,7))``
stands for::

  1  2
  5  7

Then 2-by-2 matrix multiplication may be defined by::

  mtxmult(a,b) = @tuplegen [@tuplegen [a[i][1]*b[1][j] + a[i][2]*b[2][j] 
                                       for j = 1 : 2]
                            for i = 1 : 2]

This definition generates unrolls into four expressions on the right-hand side and
works as expected::

   julia> mtxmult(((1,2),(5,7)),((4,1),(2,8)))
   ((8,17),(34,61))



As with the ``@unroll``
macro, the loop bounds for ``@tuplegen``
must be known at macro-expansion time.
In particular, the following plausible attempt to define a generic function for
addition of arbitrary
fixed-length tuples (so that ``(1,7)+(-2,3)`` yields ``(-1,10)``) does not work::

  +{N}(a::NTuple{N}, b::NTuple{N}) = @tuplegen [a[i]+b[i] for i=1:N]

because the type parameter ``N`` is not known at the time of macro expansion; instead
it is determined later by the dispatch mechanism.  If someone knows how to fix
this, please create an issue or pull request.  (It is possible to write generic
addition for tuples via the more complicated generated-function mechanism.)



-----------------
Cautionary notes
-----------------

  * The
    loop index must be a simple variable (e.g., the loop cannot be
    of the form ``for (k,v) in mydict`` or something similar). 

  * The loop index is matched symbolically by the macro.  This
    means that the same symbol may not be used in the loop body 
    with a different meaning (e.g., qualified by a different module name).

  * If the loop index is somehow concealed inside the loop body,
    say with an eval/parse statement, then the macro will fail.

  * The macro calls ``eval`` to obtain the loop bounds and also 
    to check whether ``if`` conditions are satisfied.  This means
    that the loop should not include statements with side effects
    (like ``print``) in either the loop bounds or in conditionals,
    since these statements may get unexpectedly executed during
    the macro expansion phase.



   
