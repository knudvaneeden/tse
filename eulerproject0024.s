// p024.s  -  Project Euler Problem 24
//
// A permutation is an ordered arrangement of objects. For example, 3124 is
// one possible permutation of the digits 1, 2, 3 and 4. If all of the
// permutations are listed numerically or alphabetically, we call it
// lexicographic order. The lexicographic permutations of 0, 1 and 2 are:
//
//   012  021  102  120  201  210
//
// What is the millionth lexicographic permutation of the digits 0-9?
//
// Method: factorial number system (factoradic).
// There are 10! = 3628800 permutations of 0..9.
// For 0-indexed position N = 999999:
//   digit[i] = N div (9-i)!,  N = N mod (9-i)!
// Pick that digit from the remaining pool each time.
//
// Version: 1.0

proc Main()
    // --- factorial table: fact[i] = i!  for i = 0..9 ---
    integer fact0, fact1, fact2, fact3, fact4
    integer fact5, fact6, fact7, fact8, fact9

    // --- pool of remaining digits (0-indexed by position) ---
    integer p0, p1, p2, p3, p4, p5, p6, p7, p8, p9

    // --- result digits ---
    integer d0, d1, d2, d3, d4, d5, d6, d7, d8, d9

    integer n           // current remainder
    integer idx         // chosen index into pool
    integer i           // loop counter
    string  result[20]  // final answer string

    // Build factorial table
    fact0 = 1
    fact1 = 1
    fact2 = 2
    fact3 = 6
    fact4 = 24
    fact5 = 120
    fact6 = 720
    fact7 = 5040
    fact8 = 40320
    fact9 = 362880

    // Initialise digit pool
    p0 = 0   p1 = 1   p2 = 2   p3 = 3   p4 = 4
    p5 = 5   p6 = 6   p7 = 7   p8 = 8   p9 = 9

    // Target: 1,000,000th permutation => 0-indexed position 999999
    n = 999999

    // --- Step 0: pick from pool using fact9 = 362880 ---
    idx = n / fact9
    n   = n mod fact9
    // read pool[idx]
    if    idx == 0  d0 = p0
    elseif idx == 1  d0 = p1
    elseif idx == 2  d0 = p2
    elseif idx == 3  d0 = p3
    elseif idx == 4  d0 = p4
    elseif idx == 5  d0 = p5
    elseif idx == 6  d0 = p6
    elseif idx == 7  d0 = p7
    elseif idx == 8  d0 = p8
    else             d0 = p9
    endif
    // remove pool[idx] by shifting left
    if idx <= 0  p0 = p1  endif
    if idx <= 1  p1 = p2  endif
    if idx <= 2  p2 = p3  endif
    if idx <= 3  p3 = p4  endif
    if idx <= 4  p4 = p5  endif
    if idx <= 5  p5 = p6  endif
    if idx <= 6  p6 = p7  endif
    if idx <= 7  p7 = p8  endif
    if idx <= 8  p8 = p9  endif

    // --- Step 1: fact8 = 40320 ---
    idx = n / fact8
    n   = n mod fact8
    if    idx == 0  d1 = p0
    elseif idx == 1  d1 = p1
    elseif idx == 2  d1 = p2
    elseif idx == 3  d1 = p3
    elseif idx == 4  d1 = p4
    elseif idx == 5  d1 = p5
    elseif idx == 6  d1 = p6
    elseif idx == 7  d1 = p7
    elseif idx == 8  d1 = p8
    else             d1 = p9
    endif
    if idx <= 0  p0 = p1  endif
    if idx <= 1  p1 = p2  endif
    if idx <= 2  p2 = p3  endif
    if idx <= 3  p3 = p4  endif
    if idx <= 4  p4 = p5  endif
    if idx <= 5  p5 = p6  endif
    if idx <= 6  p6 = p7  endif
    if idx <= 7  p7 = p8  endif

    // --- Step 2: fact7 = 5040 ---
    idx = n / fact7
    n   = n mod fact7
    if    idx == 0  d2 = p0
    elseif idx == 1  d2 = p1
    elseif idx == 2  d2 = p2
    elseif idx == 3  d2 = p3
    elseif idx == 4  d2 = p4
    elseif idx == 5  d2 = p5
    elseif idx == 6  d2 = p6
    elseif idx == 7  d2 = p7
    else             d2 = p8
    endif
    if idx <= 0  p0 = p1  endif
    if idx <= 1  p1 = p2  endif
    if idx <= 2  p2 = p3  endif
    if idx <= 3  p3 = p4  endif
    if idx <= 4  p4 = p5  endif
    if idx <= 5  p5 = p6  endif
    if idx <= 6  p6 = p7  endif

    // --- Step 3: fact6 = 720 ---
    idx = n / fact6
    n   = n mod fact6
    if    idx == 0  d3 = p0
    elseif idx == 1  d3 = p1
    elseif idx == 2  d3 = p2
    elseif idx == 3  d3 = p3
    elseif idx == 4  d3 = p4
    elseif idx == 5  d3 = p5
    elseif idx == 6  d3 = p6
    else             d3 = p7
    endif
    if idx <= 0  p0 = p1  endif
    if idx <= 1  p1 = p2  endif
    if idx <= 2  p2 = p3  endif
    if idx <= 3  p3 = p4  endif
    if idx <= 4  p4 = p5  endif
    if idx <= 5  p5 = p6  endif

    // --- Step 4: fact5 = 120 ---
    idx = n / fact5
    n   = n mod fact5
    if    idx == 0  d4 = p0
    elseif idx == 1  d4 = p1
    elseif idx == 2  d4 = p2
    elseif idx == 3  d4 = p3
    elseif idx == 4  d4 = p4
    elseif idx == 5  d4 = p5
    else             d4 = p6
    endif
    if idx <= 0  p0 = p1  endif
    if idx <= 1  p1 = p2  endif
    if idx <= 2  p2 = p3  endif
    if idx <= 3  p3 = p4  endif
    if idx <= 4  p4 = p5  endif

    // --- Step 5: fact4 = 24 ---
    idx = n / fact4
    n   = n mod fact4
    if    idx == 0  d5 = p0
    elseif idx == 1  d5 = p1
    elseif idx == 2  d5 = p2
    elseif idx == 3  d5 = p3
    elseif idx == 4  d5 = p4
    else             d5 = p5
    endif
    if idx <= 0  p0 = p1  endif
    if idx <= 1  p1 = p2  endif
    if idx <= 2  p2 = p3  endif
    if idx <= 3  p3 = p4  endif

    // --- Step 6: fact3 = 6 ---
    idx = n / fact3
    n   = n mod fact3
    if    idx == 0  d6 = p0
    elseif idx == 1  d6 = p1
    elseif idx == 2  d6 = p2
    elseif idx == 3  d6 = p3
    else             d6 = p4
    endif
    if idx <= 0  p0 = p1  endif
    if idx <= 1  p1 = p2  endif
    if idx <= 2  p2 = p3  endif

    // --- Step 7: fact2 = 2 ---
    idx = n / fact2
    n   = n mod fact2
    if    idx == 0  d7 = p0
    elseif idx == 1  d7 = p1
    elseif idx == 2  d7 = p2
    else             d7 = p3
    endif
    if idx <= 0  p0 = p1  endif
    if idx <= 1  p1 = p2  endif

    // --- Step 8: fact1 = 1 ---
    idx = n / fact1
    n   = n mod fact1
    if    idx == 0  d8 = p0
    elseif idx == 1  d8 = p1
    else             d8 = p2
    endif
    if idx <= 0  p0 = p1  endif

    // --- Step 9: last remaining digit ---
    d9 = p0

    // Build result string
    result = Str(d0) + Str(d1) + Str(d2) + Str(d3) + Str(d4) +
             Str(d5) + Str(d6) + Str(d7) + Str(d8) + Str(d9)

    Warn("Project Euler #24 - Millionth lexicographic permutation of 0-9:" +
         Chr(13) + result)
    CopyToWinClip(result)
end

