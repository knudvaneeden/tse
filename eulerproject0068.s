// ===========================================================================
// euler68.s  -  Project Euler Problem 68
//               "Magic 5-gon Ring"
//
// Author=Perplexity Computer
//
// Find the maximum 16-digit string for a magic 5-gon ring
// using the numbers 1 to 10.
//
// RING STRUCTURE (clockwise, 5 outer + 5 inner nodes):
//
// Each "line" k (k = 0..4):
//   outer[k], inner[k], inner[(k+1) mod 5]
//
// All five line sums must equal the same total T.
//
// Encoding (no arrays in TSE SAL - individual variables used):
//   outer nodes: o1, o2, o3, o4, o5
//   inner nodes: n1, n2, n3, n4, n5
//
// Lines:
//   Line 0: o1 + n1 + n2
//   Line 1: o2 + n2 + n3
//   Line 2: o3 + n3 + n4
//   Line 3: o4 + n4 + n5
//   Line 4: o5 + n5 + n1
//
// The description string is built clockwise from the group whose
// outer node is numerically lowest.
//
// NOTE: The number 10 is two digits. Only when 10 is an OUTER node
// does it appear once => 16-digit result. If 10 were an inner node
// it appears in two lines => 17-digit result (discarded).
//
// EXPECTED ANSWER: 6531031914842725
//
// To run in TSE Pro:
//   1. Open this file.
//   2. Macro -> Execute Macro  (or press the assigned key).
// ===========================================================================

// ---------------------------------------------------------------------------
// StrGT  -  return TRUE if string a is lexicographically greater than b
// ---------------------------------------------------------------------------
integer proc StrGT( string a, string b )
    integer la, lb, i
    la = Length( a )
    lb = Length( b )
    if la <> lb
        return( la > lb )
    endif
    for i = 1 to la
        if Asc( a[ i ] ) > Asc( b[ i ] )
            return( TRUE )
        elseif Asc( a[ i ] ) < Asc( b[ i ] )
            return( FALSE )
        endif
    endfor
    return( FALSE )   // equal
end

// ---------------------------------------------------------------------------
// BuildString
//   Given outer nodes o1..o5 and inner nodes n1..n5,
//   find the minimum outer node, then concatenate the five triples
//   clockwise starting from that node.
//   Returns the concatenated string.
// ---------------------------------------------------------------------------
string proc BuildString( integer o1, integer o2, integer o3, integer o4, integer o5,
                         integer n1, integer n2, integer n3, integer n4, integer n5 )
    integer minVal, minIdx
    string  s[ 20 ]

    // Find index (1-based) of smallest outer node
    minVal = o1   minIdx = 1
    if o2 < minVal   minVal = o2   minIdx = 2   endif
    if o3 < minVal   minVal = o3   minIdx = 3   endif
    if o4 < minVal   minVal = o4   minIdx = 4   endif
    if o5 < minVal                 minIdx = 5   endif

    // Build string clockwise from minIdx
    // Line sequence: (minIdx-1) mod 5 ... but we just use a case on minIdx.
    // Each line is: outer[k], inner[k], inner[(k mod 5)+1]
    // Reorder the five triples so we start at minIdx.
    s = ""
    if minIdx == 1
        s = Str(o1)+Str(n1)+Str(n2) + Str(o2)+Str(n2)+Str(n3) + Str(o3)+Str(n3)+Str(n4) + Str(o4)+Str(n4)+Str(n5) + Str(o5)+Str(n5)+Str(n1)
    elseif minIdx == 2
        s = Str(o2)+Str(n2)+Str(n3) + Str(o3)+Str(n3)+Str(n4) + Str(o4)+Str(n4)+Str(n5) + Str(o5)+Str(n5)+Str(n1) + Str(o1)+Str(n1)+Str(n2)
    elseif minIdx == 3
        s = Str(o3)+Str(n3)+Str(n4) + Str(o4)+Str(n4)+Str(n5) + Str(o5)+Str(n5)+Str(n1) + Str(o1)+Str(n1)+Str(n2) + Str(o2)+Str(n2)+Str(n3)
    elseif minIdx == 4
        s = Str(o4)+Str(n4)+Str(n5) + Str(o5)+Str(n5)+Str(n1) + Str(o1)+Str(n1)+Str(n2) + Str(o2)+Str(n2)+Str(n3) + Str(o3)+Str(n3)+Str(n4)
    else
        s = Str(o5)+Str(n5)+Str(n1) + Str(o1)+Str(n1)+Str(n2) + Str(o2)+Str(n2)+Str(n3) + Str(o3)+Str(n3)+Str(n4) + Str(o4)+Str(n4)+Str(n5)
    endif
    return( s )
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    // Outer nodes
    integer o1, o2, o3, o4, o5
    // Inner nodes
    integer n1, n2, n3, n4, n5
    // used flags - one per value 1..10
    integer u1, u2, u3, u4, u5, u6, u7, u8, u9, u10
    integer total
    string  candidate[ 20 ]
    string  best[ 20 ]

    best = ""

    // Ten nested loops: o1..o5 then n1..n5
    // used flags track which values 1-10 are already placed.
    // Macro to set/clear the correct used flag by value is expanded inline.

    for o1 = 1 to 10
        // mark o1 used
        u1=FALSE u2=FALSE u3=FALSE u4=FALSE u5=FALSE
        u6=FALSE u7=FALSE u8=FALSE u9=FALSE u10=FALSE
        if o1==1  u1=TRUE  elseif o1==2  u2=TRUE  elseif o1==3  u3=TRUE
        elseif o1==4  u4=TRUE  elseif o1==5  u5=TRUE  elseif o1==6  u6=TRUE
        elseif o1==7  u7=TRUE  elseif o1==8  u8=TRUE  elseif o1==9  u9=TRUE
        else  u10=TRUE  endif

      for o2 = 1 to 10
        if (o2==1 and not u1) or (o2==2 and not u2) or (o2==3 and not u3) or
           (o2==4 and not u4) or (o2==5 and not u5) or (o2==6 and not u6) or
           (o2==7 and not u7) or (o2==8 and not u8) or (o2==9 and not u9) or
           (o2==10 and not u10)
            if o2==1  u1=TRUE  elseif o2==2  u2=TRUE  elseif o2==3  u3=TRUE
            elseif o2==4  u4=TRUE  elseif o2==5  u5=TRUE  elseif o2==6  u6=TRUE
            elseif o2==7  u7=TRUE  elseif o2==8  u8=TRUE  elseif o2==9  u9=TRUE
            else  u10=TRUE  endif

          for o3 = 1 to 10
            if (o3==1 and not u1) or (o3==2 and not u2) or (o3==3 and not u3) or
               (o3==4 and not u4) or (o3==5 and not u5) or (o3==6 and not u6) or
               (o3==7 and not u7) or (o3==8 and not u8) or (o3==9 and not u9) or
               (o3==10 and not u10)
                if o3==1  u1=TRUE  elseif o3==2  u2=TRUE  elseif o3==3  u3=TRUE
                elseif o3==4  u4=TRUE  elseif o3==5  u5=TRUE  elseif o3==6  u6=TRUE
                elseif o3==7  u7=TRUE  elseif o3==8  u8=TRUE  elseif o3==9  u9=TRUE
                else  u10=TRUE  endif

              for o4 = 1 to 10
                if (o4==1 and not u1) or (o4==2 and not u2) or (o4==3 and not u3) or
                   (o4==4 and not u4) or (o4==5 and not u5) or (o4==6 and not u6) or
                   (o4==7 and not u7) or (o4==8 and not u8) or (o4==9 and not u9) or
                   (o4==10 and not u10)
                    if o4==1  u1=TRUE  elseif o4==2  u2=TRUE  elseif o4==3  u3=TRUE
                    elseif o4==4  u4=TRUE  elseif o4==5  u5=TRUE  elseif o4==6  u6=TRUE
                    elseif o4==7  u7=TRUE  elseif o4==8  u8=TRUE  elseif o4==9  u9=TRUE
                    else  u10=TRUE  endif

                  for o5 = 1 to 10
                    if (o5==1 and not u1) or (o5==2 and not u2) or (o5==3 and not u3) or
                       (o5==4 and not u4) or (o5==5 and not u5) or (o5==6 and not u6) or
                       (o5==7 and not u7) or (o5==8 and not u8) or (o5==9 and not u9) or
                       (o5==10 and not u10)
                        if o5==1  u1=TRUE  elseif o5==2  u2=TRUE  elseif o5==3  u3=TRUE
                        elseif o5==4  u4=TRUE  elseif o5==5  u5=TRUE  elseif o5==6  u6=TRUE
                        elseif o5==7  u7=TRUE  elseif o5==8  u8=TRUE  elseif o5==9  u9=TRUE
                        else  u10=TRUE  endif

                      for n1 = 1 to 10
                        if (n1==1 and not u1) or (n1==2 and not u2) or (n1==3 and not u3) or
                           (n1==4 and not u4) or (n1==5 and not u5) or (n1==6 and not u6) or
                           (n1==7 and not u7) or (n1==8 and not u8) or (n1==9 and not u9) or
                           (n1==10 and not u10)
                            if n1==1  u1=TRUE  elseif n1==2  u2=TRUE  elseif n1==3  u3=TRUE
                            elseif n1==4  u4=TRUE  elseif n1==5  u5=TRUE  elseif n1==6  u6=TRUE
                            elseif n1==7  u7=TRUE  elseif n1==8  u8=TRUE  elseif n1==9  u9=TRUE
                            else  u10=TRUE  endif

                          for n2 = 1 to 10
                            if (n2==1 and not u1) or (n2==2 and not u2) or (n2==3 and not u3) or
                               (n2==4 and not u4) or (n2==5 and not u5) or (n2==6 and not u6) or
                               (n2==7 and not u7) or (n2==8 and not u8) or (n2==9 and not u9) or
                               (n2==10 and not u10)
                                // Line 0 fixes the target total
                                total = o1 + n1 + n2

                                if n2==1  u1=TRUE  elseif n2==2  u2=TRUE  elseif n2==3  u3=TRUE
                                elseif n2==4  u4=TRUE  elseif n2==5  u5=TRUE  elseif n2==6  u6=TRUE
                                elseif n2==7  u7=TRUE  elseif n2==8  u8=TRUE  elseif n2==9  u9=TRUE
                                else  u10=TRUE  endif

                              for n3 = 1 to 10
                                if (n3==1 and not u1) or (n3==2 and not u2) or (n3==3 and not u3) or
                                   (n3==4 and not u4) or (n3==5 and not u5) or (n3==6 and not u6) or
                                   (n3==7 and not u7) or (n3==8 and not u8) or (n3==9 and not u9) or
                                   (n3==10 and not u10)
                                    // Prune: line 1
                                    if o2 + n2 + n3 == total
                                        if n3==1  u1=TRUE  elseif n3==2  u2=TRUE  elseif n3==3  u3=TRUE
                                        elseif n3==4  u4=TRUE  elseif n3==5  u5=TRUE  elseif n3==6  u6=TRUE
                                        elseif n3==7  u7=TRUE  elseif n3==8  u8=TRUE  elseif n3==9  u9=TRUE
                                        else  u10=TRUE  endif

                                      for n4 = 1 to 10
                                        if (n4==1 and not u1) or (n4==2 and not u2) or (n4==3 and not u3) or
                                           (n4==4 and not u4) or (n4==5 and not u5) or (n4==6 and not u6) or
                                           (n4==7 and not u7) or (n4==8 and not u8) or (n4==9 and not u9) or
                                           (n4==10 and not u10)
                                            // Prune: line 2
                                            if o3 + n3 + n4 == total
                                                if n4==1  u1=TRUE  elseif n4==2  u2=TRUE  elseif n4==3  u3=TRUE
                                                elseif n4==4  u4=TRUE  elseif n4==5  u5=TRUE  elseif n4==6  u6=TRUE
                                                elseif n4==7  u7=TRUE  elseif n4==8  u8=TRUE  elseif n4==9  u9=TRUE
                                                else  u10=TRUE  endif

                                                // n5 is the one remaining value
                                                n5 = 55 - o1 - o2 - o3 - o4 - o5 - n1 - n2 - n3 - n4
                                                // (sum 1..10 = 55)

                                                if n5 >= 1 and n5 <= 10
                                                    // Prune: lines 3 and 4
                                                    if o4 + n4 + n5 == total
                                                    if o5 + n5 + n1 == total
                                                        // *** Valid magic 5-gon ring ***
                                                        candidate = BuildString( o1, o2, o3, o4, o5,
                                                                                 n1, n2, n3, n4, n5 )
                                                        // Keep only 16-digit strings
                                                        if Length( candidate ) == 16
                                                            if StrGT( candidate, best )
                                                                best = candidate
                                                            endif
                                                        endif
                                                    endif  // line 4
                                                    endif  // line 3
                                                endif  // n5 in range

                                                if n4==1  u1=FALSE  elseif n4==2  u2=FALSE  elseif n4==3  u3=FALSE
                                                elseif n4==4  u4=FALSE  elseif n4==5  u5=FALSE  elseif n4==6  u6=FALSE
                                                elseif n4==7  u7=FALSE  elseif n4==8  u8=FALSE  elseif n4==9  u9=FALSE
                                                else  u10=FALSE  endif
                                            endif  // line 2
                                        endif  // not used n4
                                      endfor  // n4

                                        if n3==1  u1=FALSE  elseif n3==2  u2=FALSE  elseif n3==3  u3=FALSE
                                        elseif n3==4  u4=FALSE  elseif n3==5  u5=FALSE  elseif n3==6  u6=FALSE
                                        elseif n3==7  u7=FALSE  elseif n3==8  u8=FALSE  elseif n3==9  u9=FALSE
                                        else  u10=FALSE  endif
                                    endif  // line 1
                                  endif  // not used n3
                                endfor  // n3

                                if n2==1  u1=FALSE  elseif n2==2  u2=FALSE  elseif n2==3  u3=FALSE
                                elseif n2==4  u4=FALSE  elseif n2==5  u5=FALSE  elseif n2==6  u6=FALSE
                                elseif n2==7  u7=FALSE  elseif n2==8  u8=FALSE  elseif n2==9  u9=FALSE
                                else  u10=FALSE  endif
                            endif  // not used n2
                          endfor  // n2

                            if n1==1  u1=FALSE  elseif n1==2  u2=FALSE  elseif n1==3  u3=FALSE
                            elseif n1==4  u4=FALSE  elseif n1==5  u5=FALSE  elseif n1==6  u6=FALSE
                            elseif n1==7  u7=FALSE  elseif n1==8  u8=FALSE  elseif n1==9  u9=FALSE
                            else  u10=FALSE  endif
                        endif  // not used n1
                      endfor  // n1

                        if o5==1  u1=FALSE  elseif o5==2  u2=FALSE  elseif o5==3  u3=FALSE
                        elseif o5==4  u4=FALSE  elseif o5==5  u5=FALSE  elseif o5==6  u6=FALSE
                        elseif o5==7  u7=FALSE  elseif o5==8  u8=FALSE  elseif o5==9  u9=FALSE
                        else  u10=FALSE  endif
                    endif  // not used o5
                  endfor  // o5

                    if o4==1  u1=FALSE  elseif o4==2  u2=FALSE  elseif o4==3  u3=FALSE
                    elseif o4==4  u4=FALSE  elseif o4==5  u5=FALSE  elseif o4==6  u6=FALSE
                    elseif o4==7  u7=FALSE  elseif o4==8  u8=FALSE  elseif o4==9  u9=FALSE
                    else  u10=FALSE  endif
                endif  // not used o4
              endfor  // o4

                if o3==1  u1=FALSE  elseif o3==2  u2=FALSE  elseif o3==3  u3=FALSE
                elseif o3==4  u4=FALSE  elseif o3==5  u5=FALSE  elseif o3==6  u6=FALSE
                elseif o3==7  u7=FALSE  elseif o3==8  u8=FALSE  elseif o3==9  u9=FALSE
                else  u10=FALSE  endif
            endif  // not used o3
          endfor  // o3

            if o2==1  u1=FALSE  elseif o2==2  u2=FALSE  elseif o2==3  u3=FALSE
            elseif o2==4  u4=FALSE  elseif o2==5  u5=FALSE  elseif o2==6  u6=FALSE
            elseif o2==7  u7=FALSE  elseif o2==8  u8=FALSE  elseif o2==9  u9=FALSE
            else  u10=FALSE  endif
        endif  // not used o2
      endfor  // o2

    endfor  // o1

    // -----------------------------------------------------------------------
    // Report result
    // -----------------------------------------------------------------------
    if Length( best ) == 0
        Warn( "Euler 68: No solution found." )
    else
        Warn( "Euler 68 - Maximum 16-digit magic 5-gon string: " + best )
        CopyToWinClip( best )
    endif

end  // Main
