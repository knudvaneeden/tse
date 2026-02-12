/* TSE 1.0 Pre-release                                   */
/* TWIDDLE() - exchange the two chars left of the cursor */
/*           - suggested key-binding: <Alt `>            */
/*           - Luigi M. Bianchi 04/24/1993               */


proc twiddle()

        left()
        left()
        replace("{.}+{.}+","\2\1","X1")

end
