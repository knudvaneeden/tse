// euler078.s
//
// Project Euler - Problem 78 : Coin Partitions
//
// Let p(n) represent the number of different ways in which n coins
// can be separated into piles.
// Find the least value of n for which p(n) is divisible by 1,000,000.
//
// Algorithm : Euler's pentagonal number theorem recurrence
//
//   p(n) = p(n-1) + p(n-2) - p(n-5) - p(n-7) + p(n-12) + p(n-15) - ...
//
// The offsets are generalised pentagonal numbers:
//   g(k) = k*(3*k - 1) / 2   for k = 1, -1, 2, -2, 3, -3, ...
//
// Signs alternate ++--++--...
//
// Because the true p(n) grows astronomically we only keep p(n) mod 1,000,000.
// We stop as soon as p(n) mod 1,000,000 == 0   (n > 0).
//
// TSE SAL constraints observed
// -------------------------------------------------------
// * NO integer arrays  -> p[] is stored in a hidden buffer,
//                         one value per line (line k+1 holds p(k))
// * 32-bit signed arithmetic only  -> all values kept mod 1,000,000
//                                     (max value 999,999 << 2^31-1)
// * Reserved words NOT used as identifiers:
//     avoided: val str and s mark old if for do while case goto halt
//              break end FALSE TRUE  and all built-in function names
// * String variables <= 255 chars  -> all Str() conversions are short
// -------------------------------------------------------

// ---------- helpers : buffer-backed array p(0..MAXN) ----------

integer pbuf_id   // handle of the hidden work buffer

// Write p(ndx) = pval  into line  ndx+1  of pbuf
proc SetP(integer ndx, integer pval)
    integer saved_id
    saved_id = GetBufferId()
    GotoBufferId(pbuf_id)
    GotoLine(ndx + 1)
    BegLine()
    KillLine()          // remove old content
    InsertLine(Str(pval))
    GotoBufferId(saved_id)
end

// Read p(ndx) from line  ndx+1  of pbuf
integer proc GetP(integer ndx)
    integer saved_id
    integer result
    saved_id = GetBufferId()
    GotoBufferId(pbuf_id)
    GotoLine(ndx + 1)
    BegLine()
    result = Val(GetText(1, 12))
    GotoBufferId(saved_id)
    return(result)
end

// ---------- main macro ----------

proc Main()
    integer MODULO      // 1,000,000
    integer MAXN        // upper search bound (answer < 100,000)
    integer coin_n      // current n being evaluated
    integer pn          // p(n) mod MODULO being accumulated
    integer step_k      // pentagonal index k = 1,2,3,...
    integer alt_pos     // +k value
    integer alt_neg     // -k value
    integer pent_pos    // g(+k)  = k*(3k-1)/2
    integer pent_neg    // g(-k)  = k*(3k+1)/2
    integer sub_idx     // index into p[] for a given pentagonal offset
    integer sign_grp    // which sign group : 0->+, 1->+, 2->-, 3->-
    integer term_cnt    // count of terms added so far (for sign cycling)
    integer answer_n    // the answer
    string  msg_txt[80] // output message string

    MODULO  = 1000000
    MAXN    = 100000

    // create hidden buffer and pre-fill with MAXN+1 lines of "0"
    pbuf_id = CreateTempBuffer()
    GotoBufferId(pbuf_id)
    coin_n = 0
    while coin_n <= MAXN
        AddLine("0")
        coin_n = coin_n + 1
    endwhile

    // base case : p(0) = 1
    SetP(0, 1)

    answer_n = -1
    coin_n   = 1

    while coin_n <= MAXN

        pn       = 0
        term_cnt = 0
        step_k   = 1

        // accumulate terms until both pentagonal offsets exceed coin_n
        while step_k <= coin_n

            alt_pos  = step_k
            alt_neg  = -step_k

            // g(+k) = k*(3k-1)/2
            pent_pos = alt_pos * (3 * alt_pos - 1) / 2

            // g(-k) = k*(3k+1)/2
            pent_neg = alt_neg * (3 * alt_neg - 1) / 2
            // note: alt_neg is negative, so alt_neg*(3*alt_neg-1)/2
            // equals step_k*(3*step_k+1)/2  (positive) -- compute directly
            pent_neg = step_k * (3 * step_k + 1) / 2

            // if both offsets already exceed coin_n we are done
            if pent_pos > coin_n
                if pent_neg > coin_n
                    step_k = coin_n + 1   // force loop exit
                endif
            endif

            if step_k <= coin_n

                // sign rule: +,+,-,-,+,+,-,-,...  governed by term_cnt
                // term_cnt 0,1 -> add;  term_cnt 2,3 -> subtract; then repeat

                // --- first term  (offset = pent_pos) ---
                if pent_pos <= coin_n
                    sub_idx  = coin_n - pent_pos
                    sign_grp = term_cnt mod 4
                    if sign_grp == 0
                        pn = pn + GetP(sub_idx)
                    endif
                    if sign_grp == 1
                        pn = pn + GetP(sub_idx)
                    endif
                    if sign_grp == 2
                        pn = pn - GetP(sub_idx)
                    endif
                    if sign_grp == 3
                        pn = pn - GetP(sub_idx)
                    endif
                    pn       = pn mod MODULO
                    if pn < 0
                        pn = pn + MODULO
                    endif
                    term_cnt = term_cnt + 1
                endif

                // --- second term  (offset = pent_neg) ---
                if pent_neg <= coin_n
                    sub_idx  = coin_n - pent_neg
                    sign_grp = term_cnt mod 4
                    if sign_grp == 0
                        pn = pn + GetP(sub_idx)
                    endif
                    if sign_grp == 1
                        pn = pn + GetP(sub_idx)
                    endif
                    if sign_grp == 2
                        pn = pn - GetP(sub_idx)
                    endif
                    if sign_grp == 3
                        pn = pn - GetP(sub_idx)
                    endif
                    pn       = pn mod MODULO
                    if pn < 0
                        pn = pn + MODULO
                    endif
                    term_cnt = term_cnt + 1
                endif

            endif

            step_k = step_k + 1

        endwhile  // step_k loop

        SetP(coin_n, pn)

        // check divisibility
        if pn == 0
            answer_n = coin_n
            coin_n   = MAXN + 1   // break out of outer loop
        endif

        if coin_n <= MAXN
            coin_n = coin_n + 1
        endif

    endwhile  // coin_n loop

    // discard work buffer
    AbandonFile(pbuf_id)

    // report result
    if answer_n >= 0
        msg_txt = "Euler 078 : least n where p(n) divisible by 1,000,000 = "
        msg_txt = msg_txt + Str(answer_n)
    else
        msg_txt = "Euler 078 : no solution found within search bound"
    endif

    CopyToWinClip(Str(answer_n))
    Warn(msg_txt)

end
