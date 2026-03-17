// euler097.s
// Project Euler - Problem 97: Large non-Mersenne Prime
// Find the last ten digits of the non-Mersenne prime: 28433 x 2^7830457 + 1
// Version: 1.0
//
// Algorithm:
//   Instead of computing 2^7830457 and then multiplying by 28433 (which
//   would require big-number arithmetic), we start the accumulator at 28433
//   and double it 7830457 times, keeping only the last 10 digits throughout.
//   This avoids any intermediate product larger than 2 * 99999 = 199998,
//   which is well within the 32-bit signed integer range (~2.1 billion).
//
//   Representation: acc = acc_hi * 100000 + acc_lo
//   where 0 <= acc_lo < 100000  and  0 <= acc_hi < 100000
//   This covers all 10-digit numbers mod 10^10.
//
// TSE SAL Rules Applied:
//   [1] No integer arrays -- only scalar integer variables are used.
//   [2] No reserved/built-in names as variables -- acc_hi, acc_lo, raw_lo,
//       raw_hi, carry_v, iter_cnt, res_str, hi_str, lo_str -- none are
//       reserved SAL keywords or built-in function names.
//   [3] No 'val' or 'pos' as variable names -- confirmed absent.
//   [4] String lengths <= 255 chars -- all strings are short (<= 40 chars).
//   [5] 32-bit integers only -- max intermediate: 2*99999+1 = 199999 < 2^31.
//   [6] No 'while 1' -- loop uses a counter flag: while iter_cnt < 7830457.
//   [7] No 'iterate'/'continue' -- nested if/endif used if needed.
//   [8] Return() always uses parentheses -- Return() used in all procedures.
//   [9] Warn() box for final answer -- Warn("Project Euler #97 answer: " + res_str).
//   [10] CopyToWinClip() clips only the bare answer string, not surrounding text.
//   [11] No paste of result into the .s program buffer.
//   [12] Version number included at top of file.

proc Main()

    // --- Variable declarations ---
    integer acc_hi      // high 5 digits of accumulator (0..99999)
    integer acc_lo      // low  5 digits of accumulator (0..99999)
    integer raw_lo      // scratch: 2 * acc_lo before splitting
    integer raw_hi      // scratch: 2 * acc_hi + carry before splitting
    integer carry_v     // carry from low word to high word (0 or 1)
    integer iter_cnt    // loop counter  (0 .. 7830457)
    string  res_str[12] // final 10-digit result as string
    string  hi_str[8]   // high-word string (zero-padded to 5 digits)
    string  lo_str[8]   // low-word string  (zero-padded to 5 digits)

    // --- Initialise accumulator to 28433 ---
    acc_hi   = 0
    acc_lo   = 28433
    iter_cnt = 0

    // --- Double 7830457 times, keeping last 10 digits ---
    // (start with acc=28433, multiply by 2 a total of 7830457 times)
    while iter_cnt < 7830457
        // Double the low word
        raw_lo  = 2 * acc_lo
        carry_v = raw_lo / 100000
        acc_lo  = raw_lo mod 100000

        // Double the high word, absorb carry
        raw_hi  = 2 * acc_hi + carry_v
        acc_hi  = raw_hi mod 100000

        iter_cnt = iter_cnt + 1
    endwhile

    // --- Add 1 (the +1 in 28433 * 2^7830457 + 1) ---
    acc_lo = acc_lo + 1
    if acc_lo >= 100000
        acc_lo = acc_lo - 100000
        acc_hi = acc_hi + 1
        if acc_hi >= 100000
            acc_hi = acc_hi - 100000
        endif
    endif

    // --- Build zero-padded 10-digit result string ---
    // High word: 5 digits, zero-padded on the left
    hi_str = Str(acc_hi)
    while Length(hi_str) < 5
        hi_str = "0" + hi_str
    endwhile

    // Low word: 5 digits, zero-padded on the left
    lo_str = Str(acc_lo)
    while Length(lo_str) < 5
        lo_str = "0" + lo_str
    endwhile

    res_str = hi_str + lo_str

    // --- Show answer in Warn() box ---
    Warn("Project Euler #97 answer: " + res_str)

    // --- Copy ONLY the bare answer to the Windows clipboard ---
    CopyToWinClip(res_str)

end
