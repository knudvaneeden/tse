// Project Euler - Problem 61: Cyclical Figurate Numbers
//
// Triangle    P(3,n) = n*(n+1)/2
// Square      P(4,n) = n*n
// Pentagonal  P(5,n) = n*(3*n-1)/2
// Hexagonal   P(6,n) = n*(2*n-1)
// Heptagonal  P(7,n) = n*(5*n-3)/2
// Octagonal   P(8,n) = n*(3*n-2)
//
// Find the sum of the only ordered set of six cyclic 4-digit numbers
// for which each polygonal type (3..8) is represented by a different number.
// Cyclic: last 2 digits of each number == first 2 digits of the next,
//         and last 2 digits of the last == first 2 digits of the first.
//
// Strategy:
//   - Generate all 4-digit numbers of each type into 6 temp buffers (bid3..bid8)
//   - Anchor on octagonal numbers (fewest candidates)
//   - Recurse: try to extend a chain by picking an unused type whose
//     numbers start with the last 2 digits of the current tail
//   - When chain length == 6, check closure (last->first)
//
// SAL constraints observed:
//   - No arrays; buffers used for storage
//   - No floats (all formulas yield integers)
//   - Recursion via proc calls; PushLocation/PopLocation for buffer nav
//   - String max 255 chars; chain stored as 6 comma-sep numbers
//   - Warn() + CopyToWinClip() for output
//   - return(value) syntax

// ---- Global buffer IDs for each polygon type (indices 0..5 = types 3..8) ----
integer g_bid3   // triangle
integer g_bid4   // square
integer g_bid5   // pentagonal
integer g_bid6   // hexagonal
integer g_bid7   // heptagonal
integer g_bid8   // octagonal

// ---- Solution storage ----
integer g_found
integer g_answer         // sum of the 6 numbers

// ---- Chain state (passed by encoding, but globals are simpler in SAL) ----
// We store the chain as 6 integers; depth tracks how many are filled
integer g_chain0
integer g_chain1
integer g_chain2
integer g_chain3
integer g_chain4
integer g_chain5
integer g_usedMask  // bitmask: bit k set => type (k+3) already used
                    // bit0=tri, bit1=sq, bit2=pent, bit3=hex, bit4=hept, bit5=oct

// ---- Helpers ----

// Return buffer id for type t (t in 3..8)
integer proc BidForType(integer t)
    if t == 3  return(g_bid3)  endif
    if t == 4  return(g_bid4)  endif
    if t == 5  return(g_bid5)  endif
    if t == 6  return(g_bid6)  endif
    if t == 7  return(g_bid7)  endif
    return(g_bid8)
end

// Return bitmask bit index for type t
integer proc BitForType(integer t)
    return(1 shl (t - 3))
end

// Generate all 4-digit numbers for polygon type t into buffer bid
proc GenPolygon(integer t, integer bid)
    integer n, v, lo
    GotoBufferId(bid)
    EmptyBuffer()
    n = 1
    while TRUE
        // Compute P(t,n)
        if t == 3
            v = n * (n + 1) / 2
        elseif t == 4
            v = n * n
        elseif t == 5
            v = n * (3 * n - 1) / 2
        elseif t == 6
            v = n * (2 * n - 1)
        elseif t == 7
            v = n * (5 * n - 3) / 2
        else   // t == 8
            v = n * (3 * n - 2)
        endif
        if v > 9999
            break
        endif
        if v >= 1000
            // Only keep if last two digits >= 10 (so next in chain also 4-digit)
            lo = v mod 100
            if lo >= 10
                AddLine(Str(v))
            endif
        endif
        n = n + 1
    endwhile
end

// Set chain value at position depth
proc SetChain(integer depth, integer nVal)
    if depth == 0  g_chain0 = nVal  endif
    if depth == 1  g_chain1 = nVal  endif
    if depth == 2  g_chain2 = nVal  endif
    if depth == 3  g_chain3 = nVal  endif
    if depth == 4  g_chain4 = nVal  endif
    if depth == 5  g_chain5 = nVal  endif
end

// First two digits of a 4-digit number
integer proc First2(integer v)
    return(v / 100)
end

// Last two digits of a 4-digit number
integer proc Last2(integer v)
    return(v mod 100)
end

// Recursive DFS: try to extend chain to length 6
// depth = current chain length (we need to add one more number)
// tailLast2 = last 2 digits of chain[depth-1] that the new number must start with
proc TryExtend(integer depth, integer tailLast2)
    integer t, bid, nLines, curLine, candidate, saveMask

    if g_found  return()  endif

    if depth == 6
        // Check closure: last 2 of chain[5] must equal first 2 of chain[0]
        if Last2(g_chain5) == First2(g_chain0)
            g_found = TRUE
            g_answer = g_chain0 + g_chain1 + g_chain2
            g_answer = g_answer + g_chain3 + g_chain4 + g_chain5
        endif
        return()
    endif

    // Try each unused type
    t = 3
    while t <= 8
        if g_found  break  endif
        if (g_usedMask & BitForType(t)) == 0
            bid = BidForType(t)
            PushLocation()
            GotoBufferId(bid)
            nLines = NumLines()
            BegFile()
            curLine = 1
            while curLine <= nLines
                if g_found  break  endif
                candidate = Val(GetText(1, CurrLineLen()))
                if First2(candidate) == tailLast2
                    SetChain(depth, candidate)
                    saveMask = g_usedMask
                    g_usedMask = g_usedMask | BitForType(t)
                    TryExtend(depth + 1, Last2(candidate))
                    g_usedMask = saveMask
                endif
                if curLine < nLines
                    Down()
                endif
                curLine = curLine + 1
            endwhile
            PopLocation()
        endif
        t = t + 1
    endwhile
end

proc Main()
    integer bid3, bid4, bid5, bid6, bid7, bid8
    integer nOct, curLine, startNum
    string  resultStr[255]

    // Create temp buffers for each polygon type
    g_bid3 = CreateTempBuffer()
    g_bid4 = CreateTempBuffer()
    g_bid5 = CreateTempBuffer()
    g_bid6 = CreateTempBuffer()
    g_bid7 = CreateTempBuffer()
    g_bid8 = CreateTempBuffer()

    // Generate 4-digit numbers for each type
    GenPolygon(3, g_bid3)
    GenPolygon(4, g_bid4)
    GenPolygon(5, g_bid5)
    GenPolygon(6, g_bid6)
    GenPolygon(7, g_bid7)
    GenPolygon(8, g_bid8)

    g_found  = FALSE
    g_answer = 0

    // Anchor: iterate over octagonal numbers as chain[0]
    // (octagonal has fewest 4-digit members => fastest pruning)
    GotoBufferId(g_bid8)
    nOct = NumLines()
    BegFile()
    curLine = 1
    while curLine <= nOct
        if g_found  break  endif
        startNum = Val(GetText(1, CurrLineLen()))
        g_chain0   = startNum
        g_usedMask = BitForType(8)   // octagonal used
        TryExtend(1, Last2(startNum))
        if curLine < nOct
            Down()
        endif
        curLine = curLine + 1
    endwhile

    // Clean up temp buffers
    AbandonFile(g_bid3)
    AbandonFile(g_bid4)
    AbandonFile(g_bid5)
    AbandonFile(g_bid6)
    AbandonFile(g_bid7)
    AbandonFile(g_bid8)

    if g_found
        resultStr = "P61 Cyclical Figurate Numbers" + Chr(13)
        resultStr = resultStr + "Chain: "
        resultStr = resultStr + Str(g_chain0) + ", " + Str(g_chain1) + ", "
        resultStr = resultStr + Str(g_chain2) + ", " + Str(g_chain3) + ", "
        resultStr = resultStr + Str(g_chain4) + ", " + Str(g_chain5)
        resultStr = resultStr + Chr(13) + "Sum = " + Str(g_answer)
        Warn(resultStr)
        // Copy just the numeric answer to clipboard
        bid3 = CreateTempBuffer()
        GotoBufferId(bid3)
        InsertText(Str(g_answer))
        MarkLine(1, 1)
        CopyToWinClip()
        AbandonFile(bid3)
    else
        Warn("P61: No solution found.")
    endif
end
