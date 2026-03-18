// euler105.s
// Project Euler - Problem 105: Special Subset Sums: Testing
// Version: 1.3
//
// For each of the 100 sets (7-12 elements each), check:
//   Rule1: No two distinct non-empty disjoint subsets have equal sums.
//   Rule2: If |B| > |C| then S(B) > S(C).
// Sum all S(A) for sets that satisfy both rules.  Answer: 73702
//
// Algorithm:
//   Enumerate all non-empty subsets via bitmask (max 2^12=4096 subsets per set).
//
//   Rule2: for each size sz, track minsum[sz] and maxsum[sz] in gbuf_min/gbuf_max.
//          Fail if minsum[sz] <= maxsum[sz-1] for any sz >= 2.
//
//   Rule1: use a presence buffer gbuf_seen (13550 lines, one per possible sum value).
//          For each subset sum sv: if gbuf_seen[sv+1] is already 1 -> duplicate -> fail.
//          Otherwise mark gbuf_seen[sv+1] = 1.
//          After the set is done, clear all marks by walking the sums again.
//          This replaces the O(n^2) insertion sort with a single O(n) pass.
//
//   Performance: max 4095 subsets per set x 100 sets = 409500 subset sum lookups total.
//
// TSE SAL rules confirmed:
//   [R1]  No integer arrays  -> all array storage via CreateTempBuffer(), one value per line
//   [R2]  'val' and 'pos' NOT used as variable names; no other reserved names used
//   [R3]  Return() always has parentheses
//   [R4]  Warn() used to display final answer
//   [R5]  CopyToWinClip() clips only the bare answer integer string
//   [R6]  No AddLine/InsertText of result into any editor buffer
//   [R7]  String accumulators declared with generous fixed size
//   [R8]  All values fit in 32-bit signed integers (max element ~1287, max set sum ~13549)
//   [R9]  Shl/Shr used as infix operators for bit shifts (e.g. mm Shr 1, bm Shl 1)

// -----------------------------------------------------------------------
// Global buffers  (created once in Main, reused across all 100 sets)
// -----------------------------------------------------------------------
integer gbuf_elems   // current set elements:  line k+1  = element[k],   k=1..ecnt
integer gbuf_sums    // subset sums:           line msk+1 = sum(mask),   msk=1..2^ecnt-1
integer gbuf_min     // min subset sum by size: line sz+1 = minsum[sz],  sz=1..ecnt
integer gbuf_max     // max subset sum by size: line sz+1 = maxsum[sz],  sz=1..ecnt
integer gbuf_seen    // presence flags:         line sv+1 = 1 if sum sv seen, else 0
                     // sized to 13550 lines (max possible subset sum = 13549)

// -----------------------------------------------------------------------
// SetBufLine: write integer wval to line lnum in buffer bid
// -----------------------------------------------------------------------
proc SetBufLine(integer bid, integer lnum, integer wval)
    GotoBufferId(bid)
    GotoLine(lnum)
    BegLine()
    KillToEol()
    InsertText(Str(wval), _INSERT_)
end

// -----------------------------------------------------------------------
// GetBufLine: read integer from line lnum in buffer bid
// -----------------------------------------------------------------------
integer proc GetBufLine(integer bid, integer lnum)
    GotoBufferId(bid)
    GotoLine(lnum)
    BegLine()
    Return(Val(GetText(1, 20)))
end

// -----------------------------------------------------------------------
// EnsureLines: pad buffer bid up to 'needed' lines with "0"
// -----------------------------------------------------------------------
proc EnsureLines(integer bid, integer needed)
    integer cur_lines
    GotoBufferId(bid)
    cur_lines = NumLines()
    while cur_lines < needed
        EndFile()
        AddLine("0")
        cur_lines = cur_lines + 1
    endwhile
end

// -----------------------------------------------------------------------
// LoadSet: parse comma-separated sline into gbuf_elems
//          returns number of elements found
// -----------------------------------------------------------------------
integer proc LoadSet(string sline)
    integer elem_cnt
    integer ci
    integer slen
    string  acc[16]
    string  ch[2]
    integer ev

    elem_cnt = 0
    acc      = ""
    slen     = Length(sline)
    ci       = 1
    while ci <= slen
        ch = SubStr(sline, ci, 1)
        if ch == ","
            if Length(acc) > 0
                ev       = Val(acc)
                elem_cnt = elem_cnt + 1
                SetBufLine(gbuf_elems, elem_cnt, ev)
                acc = ""
            endif
        else
            acc = acc + ch
        endif
        ci = ci + 1
    endwhile
    if Length(acc) > 0
        ev       = Val(acc)
        elem_cnt = elem_cnt + 1
        SetBufLine(gbuf_elems, elem_cnt, ev)
    endif
    Return(elem_cnt)
end

// -----------------------------------------------------------------------
// PopCount: count of set bits in msk
// -----------------------------------------------------------------------
integer proc PopCount(integer msk)
    integer pc
    integer mm
    pc = 0
    mm = msk
    while mm > 0
        pc = pc + (mm & 1)
        mm = mm Shr 1
    endwhile
    Return(pc)
end

// -----------------------------------------------------------------------
// SubsetSum: sum elements of gbuf_elems selected by bitmask msk
// -----------------------------------------------------------------------
integer proc SubsetSum(integer msk, integer ecnt)
    integer sm
    integer bi
    integer bm
    sm = 0
    bi = 1
    bm = 1
    while bi <= ecnt
        if (msk & bm) <> 0
            sm = sm + GetBufLine(gbuf_elems, bi)
        endif
        bi = bi + 1
        bm = bm Shl 1
    endwhile
    Return(sm)
end

// -----------------------------------------------------------------------
// IsSpecial: returns 1 if current set (ecnt elements in gbuf_elems) is special
// -----------------------------------------------------------------------
integer proc IsSpecial(integer ecnt)
    integer total_masks
    integer msk
    integer pc_m
    integer sm
    integer sz
    integer mn
    integer mx
    integer ok

    // total_masks = 2^ecnt
    total_masks = 1
    sz = ecnt
    while sz > 0
        total_masks = total_masks * 2
        sz = sz - 1
    endwhile
    // Non-empty subset masks: 1 .. total_masks-1
    // Stored at gbuf_sums lines 2 .. total_masks

    EnsureLines(gbuf_sums, total_masks)

    // ---- Build all subset sums ----
    msk = 1
    while msk < total_masks
        sm = SubsetSum(msk, ecnt)
        SetBufLine(gbuf_sums, msk + 1, sm)
        msk = msk + 1
    endwhile

    // ---- Rule 2 check ----
    // Initialise min/max buffers
    EnsureLines(gbuf_min, ecnt + 2)
    EnsureLines(gbuf_max, ecnt + 2)
    sz = 1
    while sz <= ecnt
        SetBufLine(gbuf_min, sz + 1, 2000000000)
        SetBufLine(gbuf_max, sz + 1, -1)
        sz = sz + 1
    endwhile
    // Fill min/max per size
    msk = 1
    while msk < total_masks
        pc_m = PopCount(msk)
        sm   = GetBufLine(gbuf_sums, msk + 1)
        mn   = GetBufLine(gbuf_min, pc_m + 1)
        mx   = GetBufLine(gbuf_max, pc_m + 1)
        if sm < mn
            SetBufLine(gbuf_min, pc_m + 1, sm)
        endif
        if sm > mx
            SetBufLine(gbuf_max, pc_m + 1, sm)
        endif
        msk = msk + 1
    endwhile
    // Verify Rule 2: minsum[sz] > maxsum[sz-1] for sz=2..ecnt
    ok = 1
    sz = 2
    while sz <= ecnt
        mn = GetBufLine(gbuf_min, sz + 1)   // minsum[sz]
        mx = GetBufLine(gbuf_max, sz)        // maxsum[sz-1]  (line = sz-1+1 = sz)
        if mn <= mx
            ok = 0
            sz = ecnt + 1   // break
        else
            sz = sz + 1
        endif
    endwhile
    if ok == 0
        Return(0)
    endif

    // ---- Rule 1 check (presence buffer, no sort needed) ----
    // Walk all subset sums; mark gbuf_seen[sm+1]=1 as we go.
    // If a slot is already 1 when we arrive -> duplicate -> fail.
    // After the check, clear all marks.
    ok  = 1
    msk = 1
    while msk < total_masks
        sm = GetBufLine(gbuf_sums, msk + 1)
        if GetBufLine(gbuf_seen, sm + 1) == 1
            ok  = 0
            msk = total_masks   // break
        else
            SetBufLine(gbuf_seen, sm + 1, 1)
        endif
        msk = msk + 1
    endwhile
    // Clear marks (walk sums again regardless of ok)
    msk = 1
    while msk < total_masks
        sm = GetBufLine(gbuf_sums, msk + 1)
        SetBufLine(gbuf_seen, sm + 1, 0)
        msk = msk + 1
    endwhile

    Return(ok)
end

// -----------------------------------------------------------------------
// SetSum: sum all ecnt elements in gbuf_elems
// -----------------------------------------------------------------------
integer proc SetSum(integer ecnt)
    integer sm
    integer ki
    sm = 0
    ki = 1
    while ki <= ecnt
        sm = sm + GetBufLine(gbuf_elems, ki)
        ki = ki + 1
    endwhile
    Return(sm)
end

// -----------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------
proc Main()
    integer grand_total
    integer set_idx
    integer ecnt
    integer sp
    integer gbuf_data
    string  ans[32]
    string  cur_line[128]

    // Create and pre-size global buffers
    gbuf_elems = CreateTempBuffer()
    gbuf_sums  = CreateTempBuffer()
    gbuf_min   = CreateTempBuffer()
    gbuf_max   = CreateTempBuffer()
    gbuf_seen  = CreateTempBuffer()

    EnsureLines(gbuf_elems, 12)
    EnsureLines(gbuf_sums,  4096)
    EnsureLines(gbuf_min,   14)
    EnsureLines(gbuf_max,   14)
    EnsureLines(gbuf_seen,  13550)  // indices 0..13549, stored at lines 1..13550

    // ---- Embedded data: all 100 sets, one per line ----
    gbuf_data = CreateTempBuffer()

    AddLine("81,88,75,42,87,84,86,65",                                    gbuf_data)
    AddLine("157,150,164,119,79,159,161,139,158",                         gbuf_data)
    AddLine("673,465,569,603,629,592,584,300,601,599,600",                gbuf_data)
    AddLine("90,85,83,84,65,87,76,46",                                    gbuf_data)
    AddLine("165,168,169,190,162,85,176,167,127",                         gbuf_data)
    AddLine("224,275,278,249,277,279,289,295,139",                        gbuf_data)
    AddLine("354,370,362,384,359,324,360,180,350,270",                    gbuf_data)
    AddLine("599,595,557,298,448,596,577,667,597,588,602",                gbuf_data)
    AddLine("175,199,137,88,187,173,168,171,174",                         gbuf_data)
    AddLine("93,187,196,144,185,178,186,202,182",                         gbuf_data)
    AddLine("157,155,81,158,119,176,152,167,159",                         gbuf_data)
    AddLine("184,165,159,166,163,167,174,124,83",                         gbuf_data)
    AddLine("1211,1212,1287,605,1208,1189,1060,1216,1243,1200,908,1210",  gbuf_data)
    AddLine("339,299,153,305,282,304,313,306,302,228",                    gbuf_data)
    AddLine("94,104,63,112,80,84,93,96",                                  gbuf_data)
    AddLine("41,88,82,85,61,74,83,81",                                    gbuf_data)
    AddLine("90,67,84,83,82,97,86,41",                                    gbuf_data)
    AddLine("299,303,151,301,291,302,307,377,333,280",                    gbuf_data)
    AddLine("55,40,48,44,25,42,41",                                       gbuf_data)
    AddLine("1038,1188,1255,1184,594,890,1173,1151,1186,1203,1187,1195",  gbuf_data)
    AddLine("76,132,133,144,135,99,128,154",                              gbuf_data)
    AddLine("77,46,108,81,85,84,93,83",                                   gbuf_data)
    AddLine("624,596,391,605,529,610,607,568,604,603,453",                gbuf_data)
    AddLine("83,167,166,189,163,174,160,165,133",                         gbuf_data)
    AddLine("308,281,389,292,346,303,302,304,300,173",                    gbuf_data)
    AddLine("593,1151,1187,1184,890,1040,1173,1186,1195,1255,1188,1203",  gbuf_data)
    AddLine("68,46,64,33,60,58,65",                                       gbuf_data)
    AddLine("65,43,88,87,86,99,93,90",                                    gbuf_data)
    AddLine("83,78,107,48,84,87,96,85",                                   gbuf_data)
    AddLine("1188,1173,1256,1038,1187,1151,890,1186,1184,1203,594,1195",  gbuf_data)
    AddLine("302,324,280,296,294,160,367,298,264,299",                    gbuf_data)
    AddLine("521,760,682,687,646,664,342,698,692,686,672",                gbuf_data)
    AddLine("56,95,86,97,96,89,108,120",                                  gbuf_data)
    AddLine("344,356,262,343,340,382,337,175,361,330",                    gbuf_data)
    AddLine("47,44,42,27,41,40,37",                                       gbuf_data)
    AddLine("139,155,161,158,118,166,154,156,78",                         gbuf_data)
    AddLine("118,157,164,158,161,79,139,150,159",                         gbuf_data)
    AddLine("299,292,371,150,300,301,281,303,306,262",                    gbuf_data)
    AddLine("85,77,86,84,44,88,91,67",                                    gbuf_data)
    AddLine("88,85,84,44,65,91,76,86",                                    gbuf_data)
    AddLine("138,141,127,96,136,154,135,76",                              gbuf_data)
    AddLine("292,308,302,346,300,324,304,305,238,166",                    gbuf_data)
    AddLine("354,342,341,257,348,343,345,321,170,301",                    gbuf_data)
    AddLine("84,178,168,167,131,170,193,166,162",                         gbuf_data)
    AddLine("686,701,706,673,694,687,652,343,683,606,518",                gbuf_data)
    AddLine("295,293,301,367,296,279,297,263,323,159",                    gbuf_data)
    AddLine("1038,1184,593,890,1188,1173,1187,1186,1195,1150,1203,1255",  gbuf_data)
    AddLine("343,364,388,402,191,383,382,385,288,374",                    gbuf_data)
    AddLine("1187,1036,1183,591,1184,1175,888,1197,1182,1219,1115,1167",  gbuf_data)
    AddLine("151,291,307,303,345,238,299,323,301,302",                    gbuf_data)
    AddLine("140,151,143,138,99,69,131,137",                              gbuf_data)
    AddLine("29,44,42,59,41,36,40",                                       gbuf_data)
    AddLine("348,329,343,344,338,315,169,359,375,271",                    gbuf_data)
    AddLine("48,39,34,37,50,40,41",                                       gbuf_data)
    AddLine("593,445,595,558,662,602,591,297,610,580,594",                gbuf_data)
    AddLine("686,651,681,342,541,687,691,707,604,675,699",                gbuf_data)
    AddLine("180,99,189,166,194,188,144,187,199",                         gbuf_data)
    AddLine("321,349,335,343,377,176,265,356,344,332",                    gbuf_data)
    AddLine("1151,1255,1195,1173,1184,1186,1188,1187,1203,593,1038,891",  gbuf_data)
    AddLine("90,88,100,83,62,113,80,89",                                  gbuf_data)
    AddLine("308,303,238,300,151,304,324,293,346,302",                    gbuf_data)
    AddLine("59,38,50,41,42,35,40",                                       gbuf_data)
    AddLine("352,366,174,355,344,265,343,310,338,331",                    gbuf_data)
    AddLine("91,89,93,90,117,85,60,106",                                  gbuf_data)
    AddLine("146,186,166,175,202,92,184,183,189",                         gbuf_data)
    AddLine("82,67,96,44,80,79,88,76",                                    gbuf_data)
    AddLine("54,50,58,66,31,61,64",                                       gbuf_data)
    AddLine("343,266,344,172,308,336,364,350,359,333",                    gbuf_data)
    AddLine("88,49,87,82,90,98,86,115",                                   gbuf_data)
    AddLine("20,47,49,51,54,48,40",                                       gbuf_data)
    AddLine("159,79,177,158,157,152,155,167,118",                         gbuf_data)
    AddLine("1219,1183,1182,1115,1035,1186,591,1197,1167,887,1184,1175",  gbuf_data)
    AddLine("611,518,693,343,704,667,686,682,677,687,725",                gbuf_data)
    AddLine("607,599,634,305,677,604,603,580,452,605,591",                gbuf_data)
    AddLine("682,686,635,675,692,730,687,342,517,658,695",                gbuf_data)
    AddLine("662,296,573,598,592,584,553,593,595,443,591",                gbuf_data)
    AddLine("180,185,186,199,187,210,93,177,149",                         gbuf_data)
    AddLine("197,136,179,185,156,182,180,178,99",                         gbuf_data)
    AddLine("271,298,218,279,285,282,280,238,140",                        gbuf_data)
    AddLine("1187,1151,890,593,1194,1188,1184,1173,1038,1186,1255,1203",  gbuf_data)
    AddLine("169,161,177,192,130,165,84,167,168",                         gbuf_data)
    AddLine("50,42,43,41,66,39,36",                                       gbuf_data)
    AddLine("590,669,604,579,448,599,560,299,601,597,598",                gbuf_data)
    AddLine("174,191,206,179,184,142,177,180,90",                         gbuf_data)
    AddLine("298,299,297,306,164,285,374,269,329,295",                    gbuf_data)
    AddLine("181,172,162,138,170,195,86,169,168",                         gbuf_data)
    AddLine("1184,1197,591,1182,1186,889,1167,1219,1183,1033,1115,1175",  gbuf_data)
    AddLine("644,695,691,679,667,687,340,681,770,686,517",                gbuf_data)
    AddLine("606,524,592,576,628,593,591,584,296,444,595",                gbuf_data)
    AddLine("94,127,154,138,135,74,136,141",                              gbuf_data)
    AddLine("179,168,172,178,177,89,198,186,137",                         gbuf_data)
    AddLine("302,299,291,300,298,149,260,305,280,370",                    gbuf_data)
    AddLine("678,517,670,686,682,768,687,648,342,692,702",                gbuf_data)
    AddLine("302,290,304,376,333,303,306,298,279,153",                    gbuf_data)
    AddLine("95,102,109,54,96,75,85,97",                                  gbuf_data)
    AddLine("150,154,146,78,152,151,162,173,119",                         gbuf_data)
    AddLine("150,143,157,152,184,112,154,151,132",                        gbuf_data)
    AddLine("36,41,54,40,25,44,42",                                       gbuf_data)
    AddLine("37,48,34,59,39,41,40",                                       gbuf_data)
    AddLine("681,603,638,611,584,303,454,607,606,605,596",                gbuf_data)

    // ---- Process each of the 100 sets ----
    grand_total = 0
    set_idx     = 0
    while set_idx < 100
        set_idx = set_idx + 1
        GotoBufferId(gbuf_data)
        GotoLine(set_idx)
        BegLine()
        cur_line = GetText(1, 127)

        ecnt = LoadSet(cur_line)
        sp   = IsSpecial(ecnt)
        if sp == 1
            grand_total = grand_total + SetSum(ecnt)
        endif
    endwhile

    // ---- Display and copy answer ----
    ans = Str(grand_total)
    Warn("Project Euler #105 answer: " + ans)
    CopyToWinClip(ans)

    // ---- Clean up ----
    AbandonFile(gbuf_elems)
    AbandonFile(gbuf_sums)
    AbandonFile(gbuf_min)
    AbandonFile(gbuf_max)
    AbandonFile(gbuf_seen)
    AbandonFile(gbuf_data)
end
