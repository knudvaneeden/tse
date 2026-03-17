// ===========================================================================
// euler074.s  -  Project Euler Problem 74: Digit Factorial Chains
// The SemWare Editor (TSE) SAL macro
// ---------------------------------------------------------------------------
//
// PROBLEM STATEMENT
// -----------------
// The number 145 is well known for the property that the sum of the
// factorial of its digits is equal to 145:
//   1! + 4! + 5! = 1 + 24 + 120 = 145
//
// There are only three loops that exist for digit-factorial chains:
//   169 -> 363601 -> 1454 -> 169
//   871 -> 45361  -> 871
//   872 -> 45362  -> 872
//
// It is not difficult to prove that EVERY starting number will eventually
// get stuck in a loop.  For example:
//   69  -> 363600 -> 1454 -> 169 -> 363601  (5 non-repeating terms)
//   78  -> 45360  -> 871  -> 45361          (4 non-repeating terms)
//   540 -> 145                              (2 non-repeating terms)
//
// Starting with 69 produces a chain of five non-repeating terms, but the
// longest non-repeating chain with a starting number below one million is
// sixty terms.
//
// QUESTION: How many chains, with a starting number below one million,
//           contain exactly sixty non-repeating terms?
// ANSWER  : 402
//
// ---------------------------------------------------------------------------
// IMPLEMENTATION NOTES (TSE SAL constraints)
// ------------------------------------------
// 1. No integer arrays  ->  digit-factorial uses an if/elseif chain.
//
// 2. Memoisation cache (1..1,000,000)  ->  a hidden TSE buffer
//    "*Euler074Cache*".  Line N holds the cached chain length for number N
//    as a plain decimal string ("0" = not yet computed).
//    Access: GotoLine(n) + GetText(1,6) / KillToEol() + InsertText().
//
// 3. Local chain storage  ->  70 unrolled integer variables v01..v70.
//    (chains never exceed 60 terms in practice)
//
// 4. Loop-detection (is 'current' already in chain?)  ->  direct integer
//    comparison against each unrolled variable via if/elseif chain.
//    NO string-based membership test: max string length in TSE SAL is 255,
//    which is too small for a pipe-delimited chain of up to 60 numbers.
//
// 5. No TSE SAL built-in names used as variable names (val, pos, left,
//    right, length, str, trim, chr, abs, max, min, up, down, copy, find,
//    replace, read, write, sort, format, set, list, process, etc.).
//
// ---------------------------------------------------------------------------
// USAGE
// -----
// 1. Load this file into TSE:  Macro -> Load.
// 2. Run:  Macro -> Execute -> Main  (or assign a key).
// 3. The answer is shown in a popup AND written to buffer *Euler074-Result*.
// ===========================================================================


// ---------------------------------------------------------------------------
// Module-level variable
// ---------------------------------------------------------------------------
integer g_cacheBufId   // buffer id of the memoisation cache buffer


// ---------------------------------------------------------------------------
// integer proc DigitFactorialSum(nNum)
//   Returns the sum of d! for each decimal digit d of nNum.
//   Uses if/elseif instead of an array (SAL has no integer arrays).
// ---------------------------------------------------------------------------
integer proc DigitFactorialSum(integer nNum)
    integer nSum, nDigit, nTmp

    nSum = 0
    nTmp = nNum
    while nTmp > 0
        nDigit = nTmp mod 10
        if    nDigit == 0   nSum = nSum + 1
        elseif nDigit == 1  nSum = nSum + 1
        elseif nDigit == 2  nSum = nSum + 2
        elseif nDigit == 3  nSum = nSum + 6
        elseif nDigit == 4  nSum = nSum + 24
        elseif nDigit == 5  nSum = nSum + 120
        elseif nDigit == 6  nSum = nSum + 720
        elseif nDigit == 7  nSum = nSum + 5040
        elseif nDigit == 8  nSum = nSum + 40320
        elseif nDigit == 9  nSum = nSum + 362880
        endif
        nTmp = nTmp / 10
    endwhile
    return(nSum)
end


// ---------------------------------------------------------------------------
// proc CacheSet(nKey, nNewLen)
//   Stores nNewLen as the cached chain length for number nKey.
//   Navigates to line nKey of g_cacheBufId and replaces its content.
// ---------------------------------------------------------------------------
proc CacheSet(integer nKey, integer nNewLen)
    integer nPrevBuf
    nPrevBuf = GetBufferId()
    GotoBufferId(g_cacheBufId)
    GotoLine(nKey)
    BegLine()
    KillToEol()
    InsertText(Str(nNewLen), _INSERT_)
    GotoBufferId(nPrevBuf)
end


// ---------------------------------------------------------------------------
// integer proc CacheGet(nKey)
//   Returns the cached chain length for nKey, or 0 if not yet computed.
// ---------------------------------------------------------------------------
integer proc CacheGet(integer nKey)
    integer nPrevBuf, nResult
    string  sCached[6]
    nPrevBuf = GetBufferId()
    GotoBufferId(g_cacheBufId)
    GotoLine(nKey)
    sCached = GetText(1, 6)
    sCached = Trim(sCached)
    if Length(sCached) == 0
        nResult = 0
    else
        nResult = Val(sCached)
    endif
    GotoBufferId(nPrevBuf)
    return(nResult)
end


// ---------------------------------------------------------------------------
// integer proc InChain(nCur, nSz,
//                      n01..n70)
//   Returns 1 if nCur matches any of n01..nSz, else 0.
//   This replaces the string-based Pos() membership test.
//   SAL max string = 255 chars, too small for a pipe-delimited chain.
// ---------------------------------------------------------------------------
integer proc InChain(integer nCur, integer nSz,
    integer n01, integer n02, integer n03, integer n04, integer n05,
    integer n06, integer n07, integer n08, integer n09, integer n10,
    integer n11, integer n12, integer n13, integer n14, integer n15,
    integer n16, integer n17, integer n18, integer n19, integer n20,
    integer n21, integer n22, integer n23, integer n24, integer n25,
    integer n26, integer n27, integer n28, integer n29, integer n30,
    integer n31, integer n32, integer n33, integer n34, integer n35,
    integer n36, integer n37, integer n38, integer n39, integer n40,
    integer n41, integer n42, integer n43, integer n44, integer n45,
    integer n46, integer n47, integer n48, integer n49, integer n50,
    integer n51, integer n52, integer n53, integer n54, integer n55,
    integer n56, integer n57, integer n58, integer n59, integer n60,
    integer n61, integer n62, integer n63, integer n64, integer n65,
    integer n66, integer n67, integer n68, integer n69, integer n70)

    integer nFound
    nFound = 0
    if nSz >= 1  and n01 == nCur  nFound = 1  endif
    if nSz >= 2  and n02 == nCur  nFound = 1  endif
    if nSz >= 3  and n03 == nCur  nFound = 1  endif
    if nSz >= 4  and n04 == nCur  nFound = 1  endif
    if nSz >= 5  and n05 == nCur  nFound = 1  endif
    if nSz >= 6  and n06 == nCur  nFound = 1  endif
    if nSz >= 7  and n07 == nCur  nFound = 1  endif
    if nSz >= 8  and n08 == nCur  nFound = 1  endif
    if nSz >= 9  and n09 == nCur  nFound = 1  endif
    if nSz >= 10 and n10 == nCur  nFound = 1  endif
    if nSz >= 11 and n11 == nCur  nFound = 1  endif
    if nSz >= 12 and n12 == nCur  nFound = 1  endif
    if nSz >= 13 and n13 == nCur  nFound = 1  endif
    if nSz >= 14 and n14 == nCur  nFound = 1  endif
    if nSz >= 15 and n15 == nCur  nFound = 1  endif
    if nSz >= 16 and n16 == nCur  nFound = 1  endif
    if nSz >= 17 and n17 == nCur  nFound = 1  endif
    if nSz >= 18 and n18 == nCur  nFound = 1  endif
    if nSz >= 19 and n19 == nCur  nFound = 1  endif
    if nSz >= 20 and n20 == nCur  nFound = 1  endif
    if nSz >= 21 and n21 == nCur  nFound = 1  endif
    if nSz >= 22 and n22 == nCur  nFound = 1  endif
    if nSz >= 23 and n23 == nCur  nFound = 1  endif
    if nSz >= 24 and n24 == nCur  nFound = 1  endif
    if nSz >= 25 and n25 == nCur  nFound = 1  endif
    if nSz >= 26 and n26 == nCur  nFound = 1  endif
    if nSz >= 27 and n27 == nCur  nFound = 1  endif
    if nSz >= 28 and n28 == nCur  nFound = 1  endif
    if nSz >= 29 and n29 == nCur  nFound = 1  endif
    if nSz >= 30 and n30 == nCur  nFound = 1  endif
    if nSz >= 31 and n31 == nCur  nFound = 1  endif
    if nSz >= 32 and n32 == nCur  nFound = 1  endif
    if nSz >= 33 and n33 == nCur  nFound = 1  endif
    if nSz >= 34 and n34 == nCur  nFound = 1  endif
    if nSz >= 35 and n35 == nCur  nFound = 1  endif
    if nSz >= 36 and n36 == nCur  nFound = 1  endif
    if nSz >= 37 and n37 == nCur  nFound = 1  endif
    if nSz >= 38 and n38 == nCur  nFound = 1  endif
    if nSz >= 39 and n39 == nCur  nFound = 1  endif
    if nSz >= 40 and n40 == nCur  nFound = 1  endif
    if nSz >= 41 and n41 == nCur  nFound = 1  endif
    if nSz >= 42 and n42 == nCur  nFound = 1  endif
    if nSz >= 43 and n43 == nCur  nFound = 1  endif
    if nSz >= 44 and n44 == nCur  nFound = 1  endif
    if nSz >= 45 and n45 == nCur  nFound = 1  endif
    if nSz >= 46 and n46 == nCur  nFound = 1  endif
    if nSz >= 47 and n47 == nCur  nFound = 1  endif
    if nSz >= 48 and n48 == nCur  nFound = 1  endif
    if nSz >= 49 and n49 == nCur  nFound = 1  endif
    if nSz >= 50 and n50 == nCur  nFound = 1  endif
    if nSz >= 51 and n51 == nCur  nFound = 1  endif
    if nSz >= 52 and n52 == nCur  nFound = 1  endif
    if nSz >= 53 and n53 == nCur  nFound = 1  endif
    if nSz >= 54 and n54 == nCur  nFound = 1  endif
    if nSz >= 55 and n55 == nCur  nFound = 1  endif
    if nSz >= 56 and n56 == nCur  nFound = 1  endif
    if nSz >= 57 and n57 == nCur  nFound = 1  endif
    if nSz >= 58 and n58 == nCur  nFound = 1  endif
    if nSz >= 59 and n59 == nCur  nFound = 1  endif
    if nSz >= 60 and n60 == nCur  nFound = 1  endif
    if nSz >= 61 and n61 == nCur  nFound = 1  endif
    if nSz >= 62 and n62 == nCur  nFound = 1  endif
    if nSz >= 63 and n63 == nCur  nFound = 1  endif
    if nSz >= 64 and n64 == nCur  nFound = 1  endif
    if nSz >= 65 and n65 == nCur  nFound = 1  endif
    if nSz >= 66 and n66 == nCur  nFound = 1  endif
    if nSz >= 67 and n67 == nCur  nFound = 1  endif
    if nSz >= 68 and n68 == nCur  nFound = 1  endif
    if nSz >= 69 and n69 == nCur  nFound = 1  endif
    if nSz >= 70 and n70 == nCur  nFound = 1  endif
    return(nFound)
end


// ---------------------------------------------------------------------------
// proc BackFill(nChainSz, nTotalLen,
//               n01..n70)
//   For each slot i (1..nChainSz), if chain[i] is <= 1,000,000 and not yet
//   cached, stores (nTotalLen - i + 1) in the cache.
//   Called after a chain terminates (loop detected or cache hit).
// ---------------------------------------------------------------------------
proc BackFill(integer nChainSz, integer nTotalLen,
    integer n01, integer n02, integer n03, integer n04, integer n05,
    integer n06, integer n07, integer n08, integer n09, integer n10,
    integer n11, integer n12, integer n13, integer n14, integer n15,
    integer n16, integer n17, integer n18, integer n19, integer n20,
    integer n21, integer n22, integer n23, integer n24, integer n25,
    integer n26, integer n27, integer n28, integer n29, integer n30,
    integer n31, integer n32, integer n33, integer n34, integer n35,
    integer n36, integer n37, integer n38, integer n39, integer n40,
    integer n41, integer n42, integer n43, integer n44, integer n45,
    integer n46, integer n47, integer n48, integer n49, integer n50,
    integer n51, integer n52, integer n53, integer n54, integer n55,
    integer n56, integer n57, integer n58, integer n59, integer n60,
    integer n61, integer n62, integer n63, integer n64, integer n65,
    integer n66, integer n67, integer n68, integer n69, integer n70)

    integer nCv, nSlot
    nSlot = 1
    while nSlot <= nChainSz
        nCv = 0
        if      nSlot ==  1  nCv = n01
        elseif  nSlot ==  2  nCv = n02
        elseif  nSlot ==  3  nCv = n03
        elseif  nSlot ==  4  nCv = n04
        elseif  nSlot ==  5  nCv = n05
        elseif  nSlot ==  6  nCv = n06
        elseif  nSlot ==  7  nCv = n07
        elseif  nSlot ==  8  nCv = n08
        elseif  nSlot ==  9  nCv = n09
        elseif  nSlot == 10  nCv = n10
        elseif  nSlot == 11  nCv = n11
        elseif  nSlot == 12  nCv = n12
        elseif  nSlot == 13  nCv = n13
        elseif  nSlot == 14  nCv = n14
        elseif  nSlot == 15  nCv = n15
        elseif  nSlot == 16  nCv = n16
        elseif  nSlot == 17  nCv = n17
        elseif  nSlot == 18  nCv = n18
        elseif  nSlot == 19  nCv = n19
        elseif  nSlot == 20  nCv = n20
        elseif  nSlot == 21  nCv = n21
        elseif  nSlot == 22  nCv = n22
        elseif  nSlot == 23  nCv = n23
        elseif  nSlot == 24  nCv = n24
        elseif  nSlot == 25  nCv = n25
        elseif  nSlot == 26  nCv = n26
        elseif  nSlot == 27  nCv = n27
        elseif  nSlot == 28  nCv = n28
        elseif  nSlot == 29  nCv = n29
        elseif  nSlot == 30  nCv = n30
        elseif  nSlot == 31  nCv = n31
        elseif  nSlot == 32  nCv = n32
        elseif  nSlot == 33  nCv = n33
        elseif  nSlot == 34  nCv = n34
        elseif  nSlot == 35  nCv = n35
        elseif  nSlot == 36  nCv = n36
        elseif  nSlot == 37  nCv = n37
        elseif  nSlot == 38  nCv = n38
        elseif  nSlot == 39  nCv = n39
        elseif  nSlot == 40  nCv = n40
        elseif  nSlot == 41  nCv = n41
        elseif  nSlot == 42  nCv = n42
        elseif  nSlot == 43  nCv = n43
        elseif  nSlot == 44  nCv = n44
        elseif  nSlot == 45  nCv = n45
        elseif  nSlot == 46  nCv = n46
        elseif  nSlot == 47  nCv = n47
        elseif  nSlot == 48  nCv = n48
        elseif  nSlot == 49  nCv = n49
        elseif  nSlot == 50  nCv = n50
        elseif  nSlot == 51  nCv = n51
        elseif  nSlot == 52  nCv = n52
        elseif  nSlot == 53  nCv = n53
        elseif  nSlot == 54  nCv = n54
        elseif  nSlot == 55  nCv = n55
        elseif  nSlot == 56  nCv = n56
        elseif  nSlot == 57  nCv = n57
        elseif  nSlot == 58  nCv = n58
        elseif  nSlot == 59  nCv = n59
        elseif  nSlot == 60  nCv = n60
        elseif  nSlot == 61  nCv = n61
        elseif  nSlot == 62  nCv = n62
        elseif  nSlot == 63  nCv = n63
        elseif  nSlot == 64  nCv = n64
        elseif  nSlot == 65  nCv = n65
        elseif  nSlot == 66  nCv = n66
        elseif  nSlot == 67  nCv = n67
        elseif  nSlot == 68  nCv = n68
        elseif  nSlot == 69  nCv = n69
        elseif  nSlot == 70  nCv = n70
        endif
        if nCv > 0 and nCv <= 1000000
            if CacheGet(nCv) == 0
                CacheSet(nCv, nTotalLen - nSlot + 1)
            endif
        endif
        nSlot = nSlot + 1
    endwhile
end


// ---------------------------------------------------------------------------
// integer proc ChainLength(nStart)
//   Returns the non-repeating chain length beginning at nStart.
//
//   Chain stored in 70 unrolled integer variables (no arrays in SAL).
//   Loop detection: InChain() compares nCurrent against each variable.
//   Cache back-fill: BackFill() updates the cache buffer after termination.
// ---------------------------------------------------------------------------
integer proc ChainLength(integer nStart)
    integer v01, v02, v03, v04, v05, v06, v07, v08, v09, v10
    integer v11, v12, v13, v14, v15, v16, v17, v18, v19, v20
    integer v21, v22, v23, v24, v25, v26, v27, v28, v29, v30
    integer v31, v32, v33, v34, v35, v36, v37, v38, v39, v40
    integer v41, v42, v43, v44, v45, v46, v47, v48, v49, v50
    integer v51, v52, v53, v54, v55, v56, v57, v58, v59, v60
    integer v61, v62, v63, v64, v65, v66, v67, v68, v69, v70

    integer nChainSz, nCurrent, nCachedLen, nTotalLen

    v01=0 v02=0 v03=0 v04=0 v05=0 v06=0 v07=0 v08=0 v09=0 v10=0
    v11=0 v12=0 v13=0 v14=0 v15=0 v16=0 v17=0 v18=0 v19=0 v20=0
    v21=0 v22=0 v23=0 v24=0 v25=0 v26=0 v27=0 v28=0 v29=0 v30=0
    v31=0 v32=0 v33=0 v34=0 v35=0 v36=0 v37=0 v38=0 v39=0 v40=0
    v41=0 v42=0 v43=0 v44=0 v45=0 v46=0 v47=0 v48=0 v49=0 v50=0
    v51=0 v52=0 v53=0 v54=0 v55=0 v56=0 v57=0 v58=0 v59=0 v60=0
    v61=0 v62=0 v63=0 v64=0 v65=0 v66=0 v67=0 v68=0 v69=0 v70=0

    nChainSz = 0
    nCurrent = nStart

    while TRUE

        // ----- Loop detection: is nCurrent already in the chain? -----
        if InChain(nCurrent, nChainSz,
                   v01,v02,v03,v04,v05,v06,v07,v08,v09,v10,
                   v11,v12,v13,v14,v15,v16,v17,v18,v19,v20,
                   v21,v22,v23,v24,v25,v26,v27,v28,v29,v30,
                   v31,v32,v33,v34,v35,v36,v37,v38,v39,v40,
                   v41,v42,v43,v44,v45,v46,v47,v48,v49,v50,
                   v51,v52,v53,v54,v55,v56,v57,v58,v59,v60,
                   v61,v62,v63,v64,v65,v66,v67,v68,v69,v70)
            BackFill(nChainSz, nChainSz,
                     v01,v02,v03,v04,v05,v06,v07,v08,v09,v10,
                     v11,v12,v13,v14,v15,v16,v17,v18,v19,v20,
                     v21,v22,v23,v24,v25,v26,v27,v28,v29,v30,
                     v31,v32,v33,v34,v35,v36,v37,v38,v39,v40,
                     v41,v42,v43,v44,v45,v46,v47,v48,v49,v50,
                     v51,v52,v53,v54,v55,v56,v57,v58,v59,v60,
                     v61,v62,v63,v64,v65,v66,v67,v68,v69,v70)
            return(nChainSz)
        endif

        // ----- Cache hit? -----
        if nCurrent <= 1000000
            nCachedLen = CacheGet(nCurrent)
            if nCachedLen > 0
                nTotalLen = nChainSz + nCachedLen
                BackFill(nChainSz, nTotalLen,
                         v01,v02,v03,v04,v05,v06,v07,v08,v09,v10,
                         v11,v12,v13,v14,v15,v16,v17,v18,v19,v20,
                         v21,v22,v23,v24,v25,v26,v27,v28,v29,v30,
                         v31,v32,v33,v34,v35,v36,v37,v38,v39,v40,
                         v41,v42,v43,v44,v45,v46,v47,v48,v49,v50,
                         v51,v52,v53,v54,v55,v56,v57,v58,v59,v60,
                         v61,v62,v63,v64,v65,v66,v67,v68,v69,v70)
                return(nTotalLen)
            endif
        endif

        // ----- Append nCurrent to chain -----
        nChainSz = nChainSz + 1
        if      nChainSz ==  1  v01 = nCurrent
        elseif  nChainSz ==  2  v02 = nCurrent
        elseif  nChainSz ==  3  v03 = nCurrent
        elseif  nChainSz ==  4  v04 = nCurrent
        elseif  nChainSz ==  5  v05 = nCurrent
        elseif  nChainSz ==  6  v06 = nCurrent
        elseif  nChainSz ==  7  v07 = nCurrent
        elseif  nChainSz ==  8  v08 = nCurrent
        elseif  nChainSz ==  9  v09 = nCurrent
        elseif  nChainSz == 10  v10 = nCurrent
        elseif  nChainSz == 11  v11 = nCurrent
        elseif  nChainSz == 12  v12 = nCurrent
        elseif  nChainSz == 13  v13 = nCurrent
        elseif  nChainSz == 14  v14 = nCurrent
        elseif  nChainSz == 15  v15 = nCurrent
        elseif  nChainSz == 16  v16 = nCurrent
        elseif  nChainSz == 17  v17 = nCurrent
        elseif  nChainSz == 18  v18 = nCurrent
        elseif  nChainSz == 19  v19 = nCurrent
        elseif  nChainSz == 20  v20 = nCurrent
        elseif  nChainSz == 21  v21 = nCurrent
        elseif  nChainSz == 22  v22 = nCurrent
        elseif  nChainSz == 23  v23 = nCurrent
        elseif  nChainSz == 24  v24 = nCurrent
        elseif  nChainSz == 25  v25 = nCurrent
        elseif  nChainSz == 26  v26 = nCurrent
        elseif  nChainSz == 27  v27 = nCurrent
        elseif  nChainSz == 28  v28 = nCurrent
        elseif  nChainSz == 29  v29 = nCurrent
        elseif  nChainSz == 30  v30 = nCurrent
        elseif  nChainSz == 31  v31 = nCurrent
        elseif  nChainSz == 32  v32 = nCurrent
        elseif  nChainSz == 33  v33 = nCurrent
        elseif  nChainSz == 34  v34 = nCurrent
        elseif  nChainSz == 35  v35 = nCurrent
        elseif  nChainSz == 36  v36 = nCurrent
        elseif  nChainSz == 37  v37 = nCurrent
        elseif  nChainSz == 38  v38 = nCurrent
        elseif  nChainSz == 39  v39 = nCurrent
        elseif  nChainSz == 40  v40 = nCurrent
        elseif  nChainSz == 41  v41 = nCurrent
        elseif  nChainSz == 42  v42 = nCurrent
        elseif  nChainSz == 43  v43 = nCurrent
        elseif  nChainSz == 44  v44 = nCurrent
        elseif  nChainSz == 45  v45 = nCurrent
        elseif  nChainSz == 46  v46 = nCurrent
        elseif  nChainSz == 47  v47 = nCurrent
        elseif  nChainSz == 48  v48 = nCurrent
        elseif  nChainSz == 49  v49 = nCurrent
        elseif  nChainSz == 50  v50 = nCurrent
        elseif  nChainSz == 51  v51 = nCurrent
        elseif  nChainSz == 52  v52 = nCurrent
        elseif  nChainSz == 53  v53 = nCurrent
        elseif  nChainSz == 54  v54 = nCurrent
        elseif  nChainSz == 55  v55 = nCurrent
        elseif  nChainSz == 56  v56 = nCurrent
        elseif  nChainSz == 57  v57 = nCurrent
        elseif  nChainSz == 58  v58 = nCurrent
        elseif  nChainSz == 59  v59 = nCurrent
        elseif  nChainSz == 60  v60 = nCurrent
        elseif  nChainSz == 61  v61 = nCurrent
        elseif  nChainSz == 62  v62 = nCurrent
        elseif  nChainSz == 63  v63 = nCurrent
        elseif  nChainSz == 64  v64 = nCurrent
        elseif  nChainSz == 65  v65 = nCurrent
        elseif  nChainSz == 66  v66 = nCurrent
        elseif  nChainSz == 67  v67 = nCurrent
        elseif  nChainSz == 68  v68 = nCurrent
        elseif  nChainSz == 69  v69 = nCurrent
        elseif  nChainSz == 70  v70 = nCurrent
        endif

        // Advance to next term
        nCurrent = DigitFactorialSum(nCurrent)

    endwhile

    return(0)   // unreachable
end


// ---------------------------------------------------------------------------
// proc InitCache
//   Creates the hidden cache buffer with 1,000,000 lines of "0".
//   Pre-seeds the eight known loop members (all <= 1,000,000).
// ---------------------------------------------------------------------------
proc InitCache()
    integer nIdx
    integer nPrevBuf

    nPrevBuf = GetBufferId()

    g_cacheBufId = GetBufferId("*Euler074Cache*")
    if g_cacheBufId == 0
        g_cacheBufId = CreateBuffer("*Euler074Cache*", _HIDDEN_)
    endif

    GotoBufferId(g_cacheBufId)
    EmptyBuffer()

    nIdx = 1
    while nIdx <= 1000000
        AddLine("0")
        nIdx = nIdx + 1
    endwhile

    // Pre-seed known loop members with correct chain lengths
    //   145    -> 1  (145 -> 145)
    //   40585  -> 1  (40585 -> 40585)
    //   169    -> 3  (169 -> 363601 -> 1454 -> 169)
    //   1454   -> 3
    //   871    -> 2  (871 -> 45361 -> 871)
    //   45361  -> 2
    //   872    -> 2  (872 -> 45362 -> 872)
    //   45362  -> 2
    //   363601 > 1,000,000, so not cached here
    GotoLine(145)   BegLine() KillToEol() InsertText("1", _INSERT_)
    GotoLine(40585) BegLine() KillToEol() InsertText("1", _INSERT_)
    GotoLine(169)   BegLine() KillToEol() InsertText("3", _INSERT_)
    GotoLine(1454)  BegLine() KillToEol() InsertText("3", _INSERT_)
    GotoLine(871)   BegLine() KillToEol() InsertText("2", _INSERT_)
    GotoLine(45361) BegLine() KillToEol() InsertText("2", _INSERT_)
    GotoLine(872)   BegLine() KillToEol() InsertText("2", _INSERT_)
    GotoLine(45362) BegLine() KillToEol() InsertText("2", _INSERT_)

    GotoBufferId(nPrevBuf)
end


// ---------------------------------------------------------------------------
// proc Main  -  macro entry point
// ---------------------------------------------------------------------------
proc Main()
    integer nIdx, nCount, nChainLen
    integer nResBufId
    string  sResultMsg[255]

    Message("Euler 074: building cache (1,000,000 lines) - please wait...")
    InitCache()

    Message("Euler 074: counting chains...")
    nCount = 0
    nIdx   = 1
    while nIdx < 1000000
        nChainLen = ChainLength(nIdx)
        if nChainLen == 60
            nCount = nCount + 1
        endif
        nIdx = nIdx + 1
    endwhile

    sResultMsg = "Chains of exactly 60 non-repeating terms below 1,000,000 = "
                 + Str(nCount)

    nResBufId = GetBufferId("*Euler074-Result*")
    if nResBufId == 0
        nResBufId = CreateBuffer("*Euler074-Result*")
    endif
    GotoBufferId(nResBufId)
    EmptyBuffer()
    AddLine("Project Euler - Problem 74: Digit Factorial Chains")
    AddLine("====================================================")
    AddLine("")
    AddLine("Question : How many chains with a starting number below")
    AddLine("           1,000,000 contain exactly 60 non-repeating terms?")
    AddLine("")
    AddLine(sResultMsg)
    AddLine("")
    AddLine("Expected : 402")
    BegFile()

    Message("Euler 074 -> " + sResultMsg)
end
