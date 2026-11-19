// REGEXENGINE storage implementation, v1.0.0.0.23.
// Portable pure SAL implementation of indexed integer slots.
// Uses TSE buffer integer variables, not unsupported C-style arrays.
// NOTE: this is slow and intended only to bootstrap compiler/runtime validation.
// Slots 1..14 are numeric; character class payload uses SetBufferStr.
// Storage indices are constrained to 1..32000.
integer gStoreBufferGI, gSourceBufferGI

string proc RxKey(integer slotI, integer idxI)
    return('R' + Str(slotI) + '_' + Str(idxI))
end

integer proc RxGet(integer slotI, integer idxI)
    if idxI < 1 or idxI > 32000 or gStoreBufferGI == 0
        return(0)
    endif
    return(GetBufferInt(RxKey(slotI,idxI),gStoreBufferGI))
end

proc RxSet(integer slotI, integer idxI, integer slotValueI)
    if idxI >= 1 and idxI <= 32000 and gStoreBufferGI <> 0
        SetBufferInt(RxKey(slotI,idxI),slotValueI,gStoreBufferGI)
    endif
end

string proc RxGetChars(integer idxI)
    if idxI < 1 or idxI > 32000 or gStoreBufferGI == 0
        return('')
    endif
    return(GetBufferStr(RxKey(15,idxI),gStoreBufferGI))
end

proc RxSetChars(integer idxI, string slotValueS)
    if idxI >= 1 and idxI <= 32000 and gStoreBufferGI <> 0
        SetBufferStr(RxKey(15,idxI),slotValueS,gStoreBufferGI)
    endif
end
