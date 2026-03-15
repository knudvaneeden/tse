/****************************************************************************
 * euler017.s  -  Project Euler Problem 17: Number Letter Counts
 *
 * Problem:
 *   If the numbers 1 to 1000 are written out in words, how many letters
 *   are used in total?
 *   NOTE: Spaces and hyphens are NOT counted.
 *         "And" IS counted (e.g. "three hundred and four" = 3+7+3+4 = 17).
 *
 * Answer: 21124
 *
 * Encoding rules used here:
 *   ones[]       = one, two, three, four, five, six, seven, eight, nine
 *   teens[]      = ten, eleven, twelve, thirteen, fourteen, fifteen,
 *                  sixteen, seventeen, eighteen, nineteen
 *   tens[]       = twenty, thirty, forty, fifty, sixty, seventy,
 *                  eighty, ninety
 *   "hundred"    = 7 letters
 *   "and"        = 3 letters  (used after "hundred" when remainder != 0)
 *   "thousand"   = 8 letters  (used for 1000 only)
 *   "onethousand"= 3 + 8 = 11 letters
 *
 * SAL constraints observed:
 *   - All variable declarations immediately after proc header
 *   - No Str() builtin -- use Format() for integer->string conversion
 *   - Integer arrays via IntArray / string arrays via StrArray (not available
 *     in TSE SAL) -- we use a sequence of constants instead
 *   - 4-space indentation, camelCase locals, g-prefix globals
 *
 * Version: 1.0
 ****************************************************************************/

// ---------------------------------------------------------------------------
// CONSTANTS  (letter counts for each word, spaces/hyphens excluded)
// ---------------------------------------------------------------------------

// ones: one(3) two(3) three(5) four(4) five(4) six(3) seven(5) eight(5) nine(4)
constant ONE_LEN    = 3
constant TWO_LEN    = 3
constant THREE_LEN  = 5
constant FOUR_LEN   = 4
constant FIVE_LEN   = 4
constant SIX_LEN    = 3
constant SEVEN_LEN  = 5
constant EIGHT_LEN  = 5
constant NINE_LEN   = 4

// teens: ten(3) eleven(6) twelve(6) thirteen(8) fourteen(8) fifteen(7)
//        sixteen(7) seventeen(9) eighteen(8) nineteen(8)
constant TEN_LEN        = 3
constant ELEVEN_LEN     = 6
constant TWELVE_LEN     = 6
constant THIRTEEN_LEN   = 8
constant FOURTEEN_LEN   = 8
constant FIFTEEN_LEN    = 7
constant SIXTEEN_LEN    = 7
constant SEVENTEEN_LEN  = 9
constant EIGHTEEN_LEN   = 8
constant NINETEEN_LEN   = 8

// tens: twenty(6) thirty(6) forty(5) fifty(5) sixty(5) seventy(7)
//       eighty(6) ninety(6)
constant TWENTY_LEN     = 6
constant THIRTY_LEN     = 6
constant FORTY_LEN      = 5
constant FIFTY_LEN      = 5
constant SIXTY_LEN      = 5
constant SEVENTY_LEN    = 7
constant EIGHTY_LEN     = 6
constant NINETY_LEN     = 6

constant HUNDRED_LEN    = 7   // "hundred"
constant AND_LEN        = 3   // "and"
constant THOUSAND_LEN   = 8   // "thousand"

// ---------------------------------------------------------------------------
// onesLetters()
//   Returns the letter count for digit d in range 1..9.
//   Returns 0 for d == 0.
// ---------------------------------------------------------------------------
integer proc onesLetters(integer d)
    case d
        when 1  return(ONE_LEN)
        when 2  return(TWO_LEN)
        when 3  return(THREE_LEN)
        when 4  return(FOUR_LEN)
        when 5  return(FIVE_LEN)
        when 6  return(SIX_LEN)
        when 7  return(SEVEN_LEN)
        when 8  return(EIGHT_LEN)
        when 9  return(NINE_LEN)
    endcase
    return(0)
end

// ---------------------------------------------------------------------------
// teensLetters()
//   Returns the letter count for numbers 10..19.
// ---------------------------------------------------------------------------
integer proc teensLetters(integer n)
    case n
        when 10  return(TEN_LEN)
        when 11  return(ELEVEN_LEN)
        when 12  return(TWELVE_LEN)
        when 13  return(THIRTEEN_LEN)
        when 14  return(FOURTEEN_LEN)
        when 15  return(FIFTEEN_LEN)
        when 16  return(SIXTEEN_LEN)
        when 17  return(SEVENTEEN_LEN)
        when 18  return(EIGHTEEN_LEN)
        when 19  return(NINETEEN_LEN)
    endcase
    return(0)
end

// ---------------------------------------------------------------------------
// tensLetters()
//   Returns the letter count for the tens word (20, 30, ... 90).
//   Only the tens-word itself; the ones digit is handled separately.
// ---------------------------------------------------------------------------
integer proc tensLetters(integer tensDigit)
    case tensDigit
        when 2  return(TWENTY_LEN)
        when 3  return(THIRTY_LEN)
        when 4  return(FORTY_LEN)
        when 5  return(FIFTY_LEN)
        when 6  return(SIXTY_LEN)
        when 7  return(SEVENTY_LEN)
        when 8  return(EIGHTY_LEN)
        when 9  return(NINETY_LEN)
    endcase
    return(0)
end

// ---------------------------------------------------------------------------
// twoDigitLetters()
//   Returns letter count for n in range 1..99.
// ---------------------------------------------------------------------------
integer proc twoDigitLetters(integer n)
    integer tens
    integer ones

    if n >= 10 and n <= 19
        return(teensLetters(n))
    endif

    tens = n / 10
    ones = n mod 10
    return(tensLetters(tens) + onesLetters(ones))
end

// ---------------------------------------------------------------------------
// numberLetters()
//   Returns the total letter count for integer n (1..1000).
//   Spaces and hyphens are NOT counted.
//   "and" IS counted when a non-zero remainder follows "hundred".
// ---------------------------------------------------------------------------
integer proc numberLetters(integer n)
    integer result
    integer hundreds
    integer remainder

    result    = 0
    hundreds  = 0
    remainder = 0

    if n == 1000
        // "one thousand" = ONE_LEN + THOUSAND_LEN
        return(ONE_LEN + THOUSAND_LEN)
    endif

    hundreds  = n / 100
    remainder = n mod 100

    if hundreds > 0
        // e.g. "three hundred"
        result = result + onesLetters(hundreds) + HUNDRED_LEN
        if remainder > 0
            // e.g. "three hundred AND four"
            result = result + AND_LEN
        endif
    endif

    if remainder > 0
        result = result + twoDigitLetters(remainder)
    endif

    return(result)
end

// ---------------------------------------------------------------------------
// euler017Main()
//   Iterates 1..1000, accumulates letter counts, displays result.
// ---------------------------------------------------------------------------
proc euler017Main()
    integer total
    integer n
    integer letters
    string  msg[80]

    total = 0
    n     = 1

    while n <= 1000
        letters = numberLetters(n)
        total   = total + letters
        n       = n + 1
    endwhile

    msg = "Project Euler Problem 17 Answer: " + Str(total)
    Warn( msg )
    CopyToWinClip( msg )
end

// ---------------------------------------------------------------------------
// Main entry point
// ---------------------------------------------------------------------------
proc Main()
    euler017Main()
end
