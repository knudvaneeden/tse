// ===========================================================================
// Project Euler - Problem 166: Criss Cross
// ===========================================================================
// A 4x4 grid filled with digits 0..9, such that all 4 rows, all 4 columns,
// and both main diagonals share the same sum S.
// Count the number of ways to fill such a grid.
//
// Grid layout:
//   a  b  c  d      row0 = a+b+c+d = S
//   e  f  g  h      row1 = e+f+g+h = S
//   i  j  k  l      row2 = i+j+k+l = S
//   m  n  o  p      row3 = m+n+o+p = S
//
//   col0: a+e+i+m=S  col1: b+f+j+n=S  col2: c+g+k+o=S  col3: d+h+l+p=S
//   diag1: a+f+k+p=S  diag2: d+g+j+m=S
//
// Derivation:
//   Given a,b,c,e,f,g,i,j and S:
//     d = S-a-b-c
//     h = S-e-f-g
//     k = (3S-2a-b-c-e-2f-g-i-j)/2   [from row3 sum = S]
//     l = S-i-j-k
//     m = S-a-e-i
//     n = S-b-f-j
//     o = S-c-g-k
//     p = S-a-f-k
//   Then check: diag2 (d+g+j+m==S), all values in [0..9], k integer.
//   Note: col3 sum is automatically satisfied when row3 sum is; no extra check needed.
//
// Answer: 7130034
//
// Version  : 1.0.0.0.1
// Author   : Claude Sonnet 4.6 (Anthropic) - generated TSE SAL solution
// Created  : 2026-03-22
// ===========================================================================
//
// History:
//   1.0.0.0.1  2026-03-22  Claude Sonnet 4.6 (Anthropic)
//              Initial version - brute force with algebraic reduction.
//              Loops over S, a,b,c,e,f,g,i,j (8 free vars + S).
//              Derives d,h,k,l,m,n,o,p algebraically.
//              Checks: integrality of k, bounds [0..9], diag2 constraint.
// ===========================================================================

// ---------------------------------------------------------------------------
// Proc: Main
// ---------------------------------------------------------------------------
proc Main()
    // Variable declarations immediately after proc header
    integer nS      // common sum S (0..36)
    integer nA      // cell a
    integer nB      // cell b
    integer nC      // cell c
    integer nD      // cell d (derived)
    integer nE      // cell e
    integer nF      // cell f
    integer nG      // cell g
    integer nH      // cell h (derived)
    integer nI      // cell i
    integer nJ      // cell j
    integer nK      // cell k (derived)
    integer nL      // cell l (derived)
    integer nM      // cell m (derived)
    integer nN      // cell n (derived)
    integer nO      // cell o (derived)
    integer nP      // cell p (derived)
    integer nNum    // numerator for k computation
    integer nCount  // grand total count
    string  sResult[255]
    //
    nCount = 0
    //
    for nS = 0 to 36
        for nA = 0 to 9
            for nB = 0 to 9
                for nC = 0 to 9
                    nD = nS - nA - nB - nC
                    if nD >= 0 and nD <= 9
                        for nE = 0 to 9
                            for nF = 0 to 9
                                for nG = 0 to 9
                                    nH = nS - nE - nF - nG
                                    if nH >= 0 and nH <= 9
                                        for nI = 0 to 9
                                            for nJ = 0 to 9
                                                // Derive k from row3 constraint:
                                                // m+n+o+p = S where:
                                                //   m=S-a-e-i, n=S-b-f-j,
                                                //   o=S-c-g-k, p=S-a-f-k
                                                // => 4S-2a-b-c-e-2f-g-i-j-2k = S
                                                // => 2k = 3S-2a-b-c-e-2f-g-i-j
                                                nNum = 3*nS - 2*nA - nB - nC - nE - 2*nF - nG - nI - nJ
                                                // k must be integer: nNum must be even
                                                if (nNum mod 2) == 0
                                                    nK = nNum / 2
                                                    if nK >= 0 and nK <= 9
                                                        nL = nS - nI - nJ - nK
                                                        if nL >= 0 and nL <= 9
                                                            nM = nS - nA - nE - nI
                                                            if nM >= 0 and nM <= 9
                                                                nN = nS - nB - nF - nJ
                                                                if nN >= 0 and nN <= 9
                                                                    nO = nS - nC - nG - nK
                                                                    if nO >= 0 and nO <= 9
                                                                        nP = nS - nA - nF - nK
                                                                        if nP >= 0 and nP <= 9
                                                                            // Check diag2: d+g+j+m == S
                                                                            if nD + nG + nJ + nM == nS
                                                                                nCount = nCount + 1
                                                                            endif
                                                                        endif
                                                                    endif
                                                                endif
                                                            endif
                                                        endif
                                                    endif
                                                endif
                                            endfor
                                        endfor
                                    endif
                                endfor
                            endfor
                        endfor
                    endif
                endfor
            endfor
        endfor
    endfor
    //
    sResult = Str( nCount )
    //
    CopyToWinClip( sResult )
    Warn( "Project Euler #166 - Criss Cross" + Chr(13) +
          "4x4 grid, digits 0-9," + Chr(13) +
          "all rows, cols, diagonals equal sum." + Chr(13) +
          Chr(13) +
          "Answer: " + sResult )
    CopyToWinClip( sResult )
end
