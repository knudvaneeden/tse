integer proc top2bits(integer x)
    integer h
    h = 0c0000000h
    h = h & x
    h = h shr 30
    h = h & 3
    return(h)
end top2bits

integer proc isqrt(integer x)
	integer a = 0	                        /* accumulator */
	integer r = 0                           /* remainder */
	integer e = 0                           /* trial product */

	integer i

	i= 0
	while ( i < 16 )
		r = (r shl 2) + top2bits(x)
		x = x shl 2
		a = a shl 1
		e = (a shl 1) + 1
		if (r >= e)
			r = r-e
			a = a+1
		endif
        i= i+1
	endwhile
    return(a)
end isqrt

proc main()
    warn("Sqrt(10): "+str(isqrt(10)))
end

