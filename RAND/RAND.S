integer z = 1
integer start, stop, seed

proc GetNumber(var integer n)
    string s[5] = Str(n)
    if Read(s)
        n = val(s)
    endif
end

/* returns number in [1 .. 2147483646] */
integer proc random()
    integer lo, hi, test
    hi= z / 127773
    lo = z mod 127773
    test = 16807 * lo - (2147483647 mod 16807) * hi
    if (test > 0)
        z = test
    else
        z = test + 2147483647
    endif
    return(z)
end

/* set the seed */
proc srandom(integer seed)
    if (seed == 0)
        seed = 1
    endif
    z = seed
end

integer proc rand(integer i1, integer i2)
    integer i, t, v
    t= random()
    i= i2-i1
    v= (t mod i)+i1
    warn(v)
    return(v)
end

Menu menurandom()
    title = "Random Generator"
    history = 5

    "&Seed"     [seed : 5]  ,   GetNumber(seed)     ,   DontClose
    "&Init Seed"            ,   srandom(seed)       ,   DontClose
    ""                      ,                       ,   Divide
    "&From"     [start : 5] ,   GetNumber(start)    ,   DontClose
    "&To"       [stop  : 5] ,   GetNumber(stop)     ,   DontClose
    ""                      ,                       ,   Divide
    "&Go"                   ,   rand(start, stop)
end

proc main()
    menurandom()
end

