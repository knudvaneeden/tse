// Project Euler - Problem 191: Prize Strings
// ============================================
// A prize string of length n over {O, L, A} qualifies if:
//   - Never 3 consecutive A's
//   - At most 1 L (late) in the entire string
//
// DP with 6 states: (lateCount in {0,1}) x (consecutiveAbsent in {0,1,2})
//   s0 = late=0, consec=0
//   s1 = late=0, consec=1
//   s2 = late=0, consec=2
//   s3 = late=1, consec=0
//   s4 = late=1, consec=1
//   s5 = late=1, consec=2
//
// Transitions per day:
//   Append O: consec -> 0, late unchanged
//   Append A: consec -> consec+1  (invalid if consec==2)
//   Append L: consec -> 0, late -> late+1  (invalid if late==1 already)
//
// Answer for n=30: 1918080160 (fits in signed 32-bit integer)
//
// <version>1.0.0.0.1</version>
// Created by: Claude (Anthropic) - claude-sonnet-4-6
// History:
//   1.0.0.0.1  2025-03-24  Initial version by Claude (Anthropic)

proc Main()
    // State variables: 6 DP states
    integer s0I = 0   // late=0, consec=0
    integer s1I = 0   // late=0, consec=1
    integer s2I = 0   // late=0, consec=2
    integer s3I = 0   // late=1, consec=0
    integer s4I = 0   // late=1, consec=1
    integer s5I = 0   // late=1, consec=2
    //
    integer n0I = 0   // new s0
    integer n1I = 0   // new s1
    integer n2I = 0   // new s2
    integer n3I = 0   // new s3
    integer n4I = 0   // new s4
    integer n5I = 0   // new s5
    //
    integer dayI    = 0
    integer totalI  = 0
    string  resS[20] = ""
    //
    // Initial state: 0 days processed, empty string -> late=0, consec=0
    s0I = 1
    s1I = 0
    s2I = 0
    s3I = 0
    s4I = 0
    s5I = 0
    //
    // Run DP for 30 days
    for dayI = 1 to 30
        // Append O: consec -> 0, late unchanged
        //   new_s0 += s0 + s1 + s2   (was late=0, append O -> late=0, consec=0)
        //   new_s3 += s3 + s4 + s5   (was late=1, append O -> late=1, consec=0)
        // Append A: consec -> consec+1, invalid if consec==2
        //   new_s1 += s0             (late=0, consec=0 -> consec=1)
        //   new_s2 += s1             (late=0, consec=1 -> consec=2)
        //   s2 discarded (consec=2 -> consec=3 = invalid)
        //   new_s4 += s3             (late=1, consec=0 -> consec=1)
        //   new_s5 += s4             (late=1, consec=1 -> consec=2)
        //   s5 discarded (consec=2 -> consec=3 = invalid)
        // Append L: consec -> 0, late -> late+1, invalid if late==1 already
        //   new_s3 += s0 + s1 + s2   (was late=0 -> late=1, consec=0)
        //   s3..s5 discarded (late already 1, appending L -> late=2 = invalid)
        //
        n0I = s0I + s1I + s2I
        n1I = s0I
        n2I = s1I
        n3I = s3I + s4I + s5I + s0I + s1I + s2I
        n4I = s3I
        n5I = s4I
        //
        s0I = n0I
        s1I = n1I
        s2I = n2I
        s3I = n3I
        s4I = n4I
        s5I = n5I
    endfor
    //
    totalI = s0I + s1I + s2I + s3I + s4I + s5I
    resS = Str( totalI )
    //
    CopyToWinClip( resS )
    Warn( "P191 Prize Strings (n=30): ", resS )
    CopyToWinClip( resS )
end
