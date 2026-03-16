// Project Euler - Problem 52: Permuted Multiples
//
// It can be seen that the number 125874 and its double 251748
// contain exactly the same digits, but in a different order.
// Find the smallest positive integer x such that
// 2x, 3x, 4x, 5x, and 6x contain the same digits.
//
// Answer: 142857

// Sort the digits of a number (given as string) using bubble sort.
// Returns a string of digits in ascending order.
string proc SortDigits(string s)
    integer i, j, n
    string  tmp[1]
    string  result[32]

    result = s
    n = Length(result)
    for i = 1 to n - 1
        for j = 1 to n - i
            if result[j:1] > result[j+1:1]
                tmp        = result[j:1]
                result[j:1]   = result[j+1:1]
                result[j+1:1] = tmp
            endif
        endfor
    endfor
    return( result )
end

// Return TRUE if x and y contain the same multiset of digits.
integer proc SameDigits(integer x, integer y)
    return( SortDigits(Str(x)) == SortDigits(Str(y)) )
end

proc Main()
    integer x
    integer found
    string  result_str[64]

    x     = 1
    found = FALSE

    while not found
        x = x + 1
        if  SameDigits(x, x * 2)
        and SameDigits(x, x * 3)
        and SameDigits(x, x * 4)
        and SameDigits(x, x * 5)
        and SameDigits(x, x * 6)
            found = TRUE
        endif
    endwhile

    result_str = Str(x)
    Warn("Project Euler #52 - Permuted Multiples:", Chr(13),
         "Smallest x where 2x..6x use same digits = ", result_str)
    CopyToWinClip(result_str)
end
