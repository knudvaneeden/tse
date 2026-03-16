// Project Euler - Problem 39: Integer Right Triangles
//
// If p is the perimeter of a right angle triangle with integral length sides
// {a,b,c}, there are exactly three solutions for p = 120:
//   {20,48,52}, {24,45,51}, {30,40,50}
// For which value of p <= 1000 is the number of solutions maximised?
//
// Approach:
//   For each perimeter p (1..1000), count integer triples {a,b,c} with
//   a <= b <= c, a+b+c = p, and a^2 + b^2 = c^2.
//   Given a and p, c = p - a - b so we iterate a from 1 to p/3,
//   b from a to (p-a)/2, derive c = p-a-b, and check Pythagoras.
//
// Answer: 840

proc Main()
    integer p
    integer a
    integer b
    integer c
    integer cnt
    integer bestP
    integer bestCnt
    string  result[80]

    bestP   = 0
    bestCnt = 0

    for p = 12 to 1000
        cnt = 0
        // a <= b <= c and a+b+c = p  =>  a <= p/3
        for a = 1 to p / 3
            // b >= a and b <= c=(p-a-b)  =>  b <= (p-a)/2
            for b = a to (p - a) / 2
                c = p - a - b
                if a * a + b * b == c * c
                    cnt = cnt + 1
                endif
            endfor
        endfor
        if cnt > bestCnt
            bestCnt = cnt
            bestP   = p
        endif
    endfor

    result = Format("P039 answer: p = ", bestP,
                    "  (", bestCnt, " solutions)")
    CopyToWinClip(Str(bestP))
    Warn(result)
end

