================
Unroll macro
================

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



   
