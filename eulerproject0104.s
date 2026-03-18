// euler104.s
// Version: 1.0
//
// Project Euler - Problem 104: "Pandigital Fibonacci Ends"
//
// Find the smallest k such that F(k) has both its first nine digits
// AND its last nine digits forming a 1-9 pandigital set
// (each of the digits 1..9 appears exactly once, no zeros).
//
// Strategy:
//
//   Last 9 digits: track fib_prev and fib_curr mod 10^9 exactly.
//     fib_prev + fib_curr < 2 * 10^9 < 2^31 - 1 (INT_MAX) -- safe before mod.
//
//   First 9 digits: track a "hi+lo" 18-digit approximation using two 32-bit integers.
//     lead_a_hi, lead_a_lo  ~  top 18 significant digits of F(k-1)
//     lead_b_hi, lead_b_lo  ~  top 18 significant digits of F(k)
//     The pair (hi, lo) represents  hi * 10^9 + lo  (but NOT as a single integer).
//     Addition with carry:
//       lo_sum = lead_a_lo + lead_b_lo
//       carry  = 1 if lo_sum >= 10^9, else 0
//       hi_sum = lead_a_hi + lead_b_hi + carry
//     Rescale when hi_sum >= 10^9 (number grew beyond 18 digits):
//       new_b_hi = hi_sum / 10
//       new_b_lo = (hi_sum mod 10) * 10^8 + lo_sum / 10
//       new_a_hi = old_b_hi / 10
//       new_a_lo = (old_b_hi mod 10) * 10^8 + old_b_lo / 10
//     No rescale:
//       new_a = old_b
//       new_b = (hi_sum, lo_sum)
//
//   Overflow checks (all values fit in signed 32-bit, max = 2,147,483,647):
//     lo_sum max = 999999999 + 999999999 = 1,999,999,998 < INT_MAX  [OK]
//     hi_sum max = 999999999 + 999999999 + 1 = 1,999,999,999 < INT_MAX  [OK]
//     (hi_sum mod 10) * 10^8 max = 9 * 100000000 = 900,000,000 < 10^9  [OK]
//     new_b_lo max = 900000000 + 99999999 = 999,999,999 < INT_MAX  [OK]
//     fib_prev + fib_curr max = 1,999,999,998 < INT_MAX  [OK]
//
//   Pandigital check: a 9-char string is 1-9 pandigital iff
//     all characters are '1'..'9' and all are distinct.
//     Use a bitmask: set bit ddig for each digit ddig; then check == 0b1111111110 = 1022.

// ---------------------------------------------------------------------------
// IsPandigital: checks if the first 9 characters of digit_str are 1-9 pandigital.
// Returns 1 (TRUE) if pandigital, 0 (FALSE) otherwise.
// ---------------------------------------------------------------------------
Integer Proc IsPandigital(String digit_str)
    Integer bitmask
    Integer dpos
    Integer dchar
    Integer ddig
    Integer dbit        // bit value for current digit: 1 shl ddig

    bitmask = 0
    dpos = 1
    While dpos <= 9
        dchar = Asc(digit_str[dpos:1])
        ddig  = dchar - 48          // '0' = ASCII 48
        If ddig < 1 Or ddig > 9
            Return(0)
        EndIf
        // dbit = 2^ddig using shl
        dbit = 1 shl ddig
        // Check for duplicate: bit test per TSE SAL docs: (m & n) <> 0
        If (bitmask & dbit) <> 0
            Return(0)               // duplicate digit -- not pandigital
        EndIf
        // Set the bit
        bitmask = bitmask | dbit
        dpos = dpos + 1
    EndWhile
    // All 9 distinct digits 1..9 => bitmask bits 1..9 all set = 1022
    If bitmask == 1022
        Return(1)
    EndIf
    Return(0)
End

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
Proc Main()
    // --- Last-9-digits tracking (exact, mod 10^9) ---
    Integer fib_prev        // F(k-1) mod 10^9
    Integer fib_curr        // F(k)   mod 10^9
    Integer fib_next        // F(k+1) mod 10^9  (temp)
    Integer MODULUS         // 10^9 = 1000000000

    // --- First-9-digits tracking (hi+lo 18-digit approximation) ---
    Integer lead_a_hi       // top 9 digits of F(k-1) (high part)
    Integer lead_a_lo       // next 9 digits of F(k-1) (low part)
    Integer lead_b_hi       // top 9 digits of F(k)
    Integer lead_b_lo       // next 9 digits of F(k)
    Integer lo_sum          // lead_a_lo + lead_b_lo
    Integer hi_sum          // lead_a_hi + lead_b_hi + carry
    Integer carry           // carry from lo into hi
    Integer new_a_hi        // temp for rescaled a_hi
    Integer new_a_lo        // temp for rescaled a_lo
    Integer SPLIT           // 10^9 = 1000000000 (rescale threshold)

    // --- Loop ---
    Integer kk              // current Fibonacci index
    Integer max_k           // safety upper limit

    // --- Pandigital check variables ---
    String  tail_str[12]    // last 9 digits as zero-padded string
    String  lead_str[12]    // first 9 digits as zero-padded string
    Integer found           // 1 when answer is found

    // --- Answer ---
    String  ans_str[16]

    // === Initialise ===
    MODULUS = 1000000000    // 10^9
    SPLIT   = 1000000000    // 10^9

    fib_prev   = 1          // F(1)
    fib_curr   = 1          // F(2)

    lead_a_hi  = 0          // F(1) = 1 -> hi=0, lo=1
    lead_a_lo  = 1
    lead_b_hi  = 0          // F(2) = 1 -> hi=0, lo=1
    lead_b_lo  = 1

    found  = 0
    kk     = 2
    max_k  = 400000

    // === Main loop: advance from F(2) up to F(max_k) ===
    While kk < max_k And found == 0

        // --- Step 1: Advance last-9-digits ---
        fib_next = fib_prev + fib_curr
        If fib_next >= MODULUS
            fib_next = fib_next - MODULUS
        EndIf
        fib_prev = fib_curr
        fib_curr = fib_next
        kk = kk + 1

        // --- Step 2: Advance first-9-digits (hi+lo representation) ---
        lo_sum = lead_a_lo + lead_b_lo
        carry  = 0
        If lo_sum >= SPLIT
            carry  = 1
            lo_sum = lo_sum - SPLIT
        EndIf
        hi_sum = lead_a_hi + lead_b_hi + carry

        If hi_sum >= SPLIT
            // Rescale: the 18-digit number overflowed, divide by 10
            new_a_hi  = lead_b_hi / 10
            new_a_lo  = (lead_b_hi Mod 10) * 100000000 + lead_b_lo / 10
            lead_b_hi = hi_sum / 10
            lead_b_lo = (hi_sum Mod 10) * 100000000 + lo_sum / 10
            lead_a_hi = new_a_hi
            lead_a_lo = new_a_lo
        Else
            lead_a_hi = lead_b_hi
            lead_a_lo = lead_b_lo
            lead_b_hi = hi_sum
            lead_b_lo = lo_sum
        EndIf

        // --- Step 3: Check last 9 digits for 1-9 pandigital ---
        // Format fib_curr as exactly 9 digits with leading zeros
        tail_str = Format(fib_curr:9:"0")

        If IsPandigital(tail_str)

            // --- Step 4: Check first 9 digits for 1-9 pandigital ---
            // lead_b_hi holds the top 9 (or fewer) significant digits
            // When lead_b_hi == 0 (early small Fibonacci numbers), use lead_b_lo
            If lead_b_hi > 0
                lead_str = Format(lead_b_hi:9:"0")
            Else
                lead_str = Format(lead_b_lo:9:"0")
            EndIf

            If IsPandigital(lead_str)
                found = 1
            EndIf

        EndIf

    EndWhile

    // === Report result ===
    If found
        ans_str = Str(kk)
        CopyToWinClip(ans_str)
        Warn("Project Euler #104 answer: k = " + ans_str)
    Else
        Warn("Project Euler #104: no answer found within limit of " + Str(max_k))
    EndIf

End
