// p042.s  -  Project Euler Problem 42: Coded Triangle Numbers
//
// The nth triangle number is t_n = n*(n+1)/2.
// Convert each letter in a word to its alphabetical position (A=1..Z=26)
// and sum them to get a word value.  If the word value is a triangle number
// the word is called a triangle word.
//
// Using p042_words.txt (nearly 2000 common English words), count how many
// are triangle words.
//
// Strategy: for a value t, solve n*(n+1)/2 = t  =>  n = (sqrt(1+8t)-1)/2
// If n is a positive integer then t is a triangle number.
//
// NOTE: The words file is one long ~16K line.  SAL strings are limited to
// 255 chars, so we CANNOT use GetText()/lineText strings to parse it.
// Instead we use fOpen/fRead to read one character at a time and build
// word tokens incrementally, which sidesteps the 255-char limit entirely.
//
// Expected answer: 162
//
// Input file : c:\temp\p042_words.txt   (comma-separated, double-quoted words)
// Version    : 1.0.0.1

string WORDS_FILE[255] = "p042_words.txt"

// -----------------------------------------------------------------------
// IntSqrt(n) - integer square root of n  (returns floor(sqrt(n)))
// Uses Newton-Raphson iteration on integers.
// -----------------------------------------------------------------------
integer proc IntSqrt(integer n)
    integer x
    integer x1
    if n <= 0
        return( 0 )
    endif
    x  = n
    x1 = (x + 1) / 2
    while x1 < x
        x  = x1
        x1 = (x + n / x) / 2
    endwhile
    return( x )
end IntSqrt

// -----------------------------------------------------------------------
// IsTriangle(t) - returns TRUE if t is a triangle number
// n = (sqrt(1 + 8*t) - 1) / 2  must be a positive integer
// -----------------------------------------------------------------------
integer proc IsTriangle(integer t)
    integer disc
    integer sq
    integer num
    if t <= 0
        return( FALSE )
    endif
    disc = 1 + 8 * t
    sq   = IntSqrt(disc)
    if sq * sq <> disc          // disc must be a perfect square
        return( FALSE )
    endif
    num = sq - 1
    if num mod 2 <> 0           // (sq-1) must be even
        return( FALSE )
    endif
    return( TRUE )              // n = num/2  is a positive integer
end IsTriangle

// -----------------------------------------------------------------------
// Main - reads file char-by-char via fOpen/fRead to avoid 255-char limit
// -----------------------------------------------------------------------
proc Main()
    integer fh
    integer triangleCount
    integer score
    integer ch
    integer inQuote
    string  buf[1]
    string  resultStr[80]

    // ----- verify input file exists ------------------------------------
    if not FileExists(WORDS_FILE)
        Warn("File not found: ", WORDS_FILE)
        return()
    endif

    fh = fOpen(WORDS_FILE, _OPEN_READONLY_)
    if fh < 0
        Warn("Cannot open: ", WORDS_FILE)
        return()
    endif

    triangleCount = 0
    score         = 0
    inQuote        = FALSE    // are we currently inside a quoted word?

    // Read one character at a time.
    // File format:  "WORD","WORD","WORD",...
    // We toggle inQuote on each double-quote character.
    // While inQuote, accumulate letter scores.
    // When inQuote turns FALSE (closing quote), test the accumulated score.

    buf = " "
    while fRead(fh, buf, 1) == 1
        ch = Asc(buf)

        if ch == Asc('"')
            if inQuote
                // closing quote - test accumulated score
                if IsTriangle(score)
                    triangleCount = triangleCount + 1
                endif
                score  = 0
                inQuote = FALSE
            else
                // opening quote
                score  = 0
                inQuote = TRUE
            endif
        elseif inQuote
            // accumulate letter value  (A/a = 1 .. Z/z = 26)
            if ch >= Asc("A") and ch <= Asc("Z")
                score = score + ch - Asc("A") + 1
            elseif ch >= Asc("a") and ch <= Asc("z")
                score = score + ch - Asc("a") + 1
            endif
        endif
    endwhile

    fClose(fh)

    // ----- report result -----------------------------------------------
    resultStr = "P042 triangle words = " + Str(triangleCount)
    CopyToWinClip(resultStr)
    Warn(resultStr, "  (answer copied to clipboard)")
end Main
