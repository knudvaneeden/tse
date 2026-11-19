// REGEXENGINE 1.0.0.0.23 - highlighted context previews for View; 75-case regression baseline
// View previews show nearby text at both endpoints of multi-line matches.
// Input grammar: TSE {} groups; [a-z] ranges; [~a-z] inverse ranges.
// Options: i casefolds plain literals; m enables \n as synthetic line boundary.
// See README for explicitly incomplete features and test status.
// Native Find() is used ONLY for conservative literal-prefix candidate selection.
// EXPERIMENTAL SOURCE: not compiled/tested against TSE 4.50.33.
// Not a complete compatibility engine; consult readme for restrictions.

#define MAX_STATES 240
#include ["regexengine.inc"]
#define MAX_POINTERS 512
#define HISTORY_REGEX 146

integer gStatesGI, gPointersGI, gPosGI, gErrorGI
integer gFragStartGI, gFragOutGI, gRootGI
string gRegexGS[255], gErrorTextGS[160]
integer gCurLineGI, gCurColGI, gLineLengthGI, gLastLineGI
integer gSeenSerialGI, gNActiveGI
integer gMatchLineGI, gMatchColGI, gEndLineGI, gEndColGI
integer gFoundCursorLineGI, gFoundCursorColGI
integer gIgnoreCaseGI, gMultilineGI
integer gCandidateCountGI
string gSearchPathGS[48]
string gIniGS[255]
string gFirstEndpointGS[255], gLastEndpointGS[255], gDecodedEndpointGS[255]
integer gWantMaximumGI
string gLogFileGS[255]
integer gLogEnabledGI
// Local (l) search: current TSE marked block, never current directory.
integer gViewGI, gViewActiveGI, gViewBufferGI
integer gViewResumeLineGI, gViewResumeColGI, gViewMaxMatchesGI, gViewResultCountGI
integer gLocalGI, gAllFilesGI, gBlockTypeGI, gBlockFirstLineGI, gBlockLastLineGI
integer gBlockFirstColGI, gBlockLastColGI
// The results-buffer preview highlights are 1-based inclusive screen spans.
// Two ranges allow a large multi-line match to color both visible endpoints.
integer gViewMark1FirstGI, gViewMark1LastGI, gViewMark2FirstGI, gViewMark2LastGI
integer gViewPaintEnabledGI

// A position is an insertion point (end coordinate is exclusive).
integer proc RxLocalPositionOK(integer lineI, integer colI)
    if not gLocalGI
        return(1)
    endif
    if lineI < gBlockFirstLineGI or lineI > gBlockLastLineGI
        return(0)
    endif
    if gBlockTypeGI == _COLUMN_
        return(colI >= gBlockFirstColGI and colI <= gBlockLastColGI + 1)
    endif
    if gBlockTypeGI == _INCLUSIVE_ or gBlockTypeGI == _NONINCLUSIVE_
        if lineI == gBlockFirstLineGI and colI < gBlockFirstColGI
            return(0)
        endif
        if lineI == gBlockLastLineGI
            if gBlockTypeGI == _INCLUSIVE_
                return(colI <= gBlockLastColGI + 1)
            endif
            return(colI <= gBlockLastColGI)
        endif
    endif
    return(1)
end

// Both endpoints must lie in the selection. Column blocks contain a
// rectangular slice on each line, so cross-line matches are disallowed.
integer proc RxLocalSpanOK(integer firstLineI, integer firstColI,
                           integer lastLineI, integer lastColI)
    if not gLocalGI
        return(1)
    endif
    if not RxLocalPositionOK(firstLineI,firstColI) or
       not RxLocalPositionOK(lastLineI,lastColI)
        return(0)
    endif
    if gBlockTypeGI == _COLUMN_ and firstLineI <> lastLineI
        return(0)
    endif
    return(1)
end


// Diagnostic events are individually opened, appended, and closed.
// The OS closes each handle before matching continues, so events survive
// a later TSE hang. This does NOT write once per character.
proc RxLog(string logMessageS)
    integer logHandleI, writeCountI
    string logLineS[255]
    if not gLogEnabledGI
        return()
    endif
    logHandleI = fOpen(gLogFileGS, _OPEN_WRITEONLY_ | _OPEN_DENYNONE_)
    if logHandleI == -1
        return()
    endif
    fSeek(logHandleI, 0, _SEEK_END_)
    logLineS = logMessageS + Chr(13) + Chr(10)
    writeCountI = fWrite(logHandleI, logLineS)
    fClose(logHandleI)
end

proc RxLogStart(string searchPatternS, string searchOptionsS)
    integer logHandleI, writeCountI
    gLogEnabledGI = 0
    logHandleI = fCreate(gLogFileGS)
    if logHandleI == -1
        Warn('Cannot create REGEXENGINE log: ',gLogFileGS)
        return()
    endif
    writeCountI = fWrite(logHandleI, 'REGEXENGINE 1.0.0.0.23 diagnostic run' + Chr(13) + Chr(10))
    fClose(logHandleI)
    gLogEnabledGI = 1
    RxLog('Pattern: ' + searchPatternS)
    RxLog('Options: ' + searchOptionsS)
end


integer proc NewState(integer kindI, integer valueI)
    if gStatesGI >= MAX_STATES
        gErrorGI = 1
        gErrorTextGS = 'Pattern exceeds 240 compiled states'
        return(0)
    endif
    gStatesGI = gStatesGI + 1
    RxSet(1,gStatesGI,kindI)
    RxSet(4,gStatesGI,valueI)
    RxSet(2,gStatesGI,0)
    RxSet(3,gStatesGI,0)
    // IMPORTANT: compiled state numbers are reused between test cases.
    // Clear the epsilon-closure visit stamp and capture slots too.
    RxSet(8,gStatesGI,0)
    RxSet(10,gStatesGI,0)
    RxSet(11,gStatesGI,0)
    RxSetChars(gStatesGI,'')
    return(gStatesGI)
end

integer proc NewPointer(integer nodeI, integer edgeI)
    if gPointersGI >= MAX_POINTERS
        gErrorGI = 1
        gErrorTextGS = 'Pattern patch table overflow'
        return(0)
    endif
    gPointersGI = gPointersGI + 1
    RxSet(5,gPointersGI,0)
    RxSet(6,gPointersGI,nodeI)
    RxSet(7,gPointersGI,edgeI)
    return(gPointersGI)
end

proc PatchList(integer firstI, integer targetI)
    integer pI, nextpI, nodeI
    pI = firstI
    while pI <> 0
        nextpI = RxGet(5,pI)
        nodeI = RxGet(6,pI)
        if RxGet(7,pI) == 1
            RxSet(2,nodeI,targetI)
        else
            RxSet(3,nodeI,targetI)
        endif
        pI = nextpI
    endwhile
end

integer proc JoinLists(integer aI, integer bI)
    integer pI
    if aI == 0
        return(bI)
    endif
    pI = aI
    while RxGet(5,pI) <> 0
        pI = RxGet(5,pI)
    endwhile
    RxSet(5,pI,bI)
    return(aI)
end

string proc Peek()
    if gPosGI > Length(gRegexGS)
        return('')
    endif
    return(SubStr(gRegexGS, gPosGI, 1))
end

string proc Take()
    string cS[2]
    cS = Peek()
    if cS <> ''
        gPosGI = gPosGI + 1
    endif
    return(cS)
end

proc MakeLeaf(integer kindI, integer slotValueI)
    integer nI
    nI = NewState(kindI, slotValueI)
    gFragStartGI = nI
    gFragOutGI = NewPointer(nI, 1)
end

// Class payload is preserved verbatim; interpreted by ClassMatches().
proc ParseClass()
    string payloadS[255], cS[2]
    integer nI, closedI
    payloadS = ''
    closedI = 0
    while Peek() <> ''
        cS = Take()
        if cS == ']'
            closedI = 1
            break
        endif
        if Length(payloadS) < 250
            payloadS = payloadS + cS
        else
            gErrorGI = 1
            gErrorTextGS = 'Character class too long'
            break
        endif
    endwhile
    if not closedI
        gErrorGI = 1
        gErrorTextGS = 'Unterminated character class'
    endif
    nI = NewState(3, 0)
    RxSetChars(nI,payloadS)
    gFragStartGI = nI
    gFragOutGI = NewPointer(nI, 1)
end

forward proc ParseExpression()

integer proc DigitVal(string cS)
    integer vI
    vI = Asc(cS)
    if vI >= 48 and vI <= 57
        return(vI - 48)
    endif
    if vI >= 65 and vI <= 70
        return(vI - 55)
    endif
    if vI >= 97 and vI <= 102
        return(vI - 87)
    endif
    return(-1)
end

proc ParseAtom()
    string cS[2], eS[2], digitS[2]
    integer kI, baseI, countDigitsI, dI, valueI
    cS = Take()
    if cS == '{'
        ParseExpression()
        if Take() <> '}'
            gErrorGI = 1
            gErrorTextGS = 'Missing closing } for group'
        endif
    elseif cS == '['
        ParseClass()
    elseif cS == '.'
        MakeLeaf(2, 0)
    elseif cS == '^'
        MakeLeaf(4, 0)
    elseif cS == '$'
        MakeLeaf(5, 0)
    elseif cS == '\'
        eS = Take()
        if eS == 'n'
            if gMultilineGI
                MakeLeaf(11, 0)  // explicit line boundary in extended mode
            else
                MakeLeaf(1, 10)  // embedded LF only, TSE-compatible mode
            endif
        elseif eS == 'r'
            MakeLeaf(1, 13)
        elseif eS == 't'
            MakeLeaf(1, 9)
        elseif eS == 'f'
            MakeLeaf(1, 12)
        elseif eS == 'c'
            MakeLeaf(10, 0)  // TSE cursor-placement marker
        elseif eS == 'b'
            MakeLeaf(1, 8)  // TSE backspace escape
        elseif eS == 'a'
            MakeLeaf(1, 7)
        elseif eS == 'v'
            MakeLeaf(1, 11)
        elseif eS == 'x' or eS == 'd' or eS == 'o'
            baseI = 10
            countDigitsI = 3
            if eS == 'x'
                baseI = 16
                countDigitsI = 2
            elseif eS == 'o'
                baseI = 8
            endif
            valueI = 0
            for kI = 1 to countDigitsI
                digitS = Take()
                dI = -1
                if digitS <> ''
                    dI = DigitVal(digitS)
                endif
                if dI < 0 or dI >= baseI
                    gErrorGI = 1
                    gErrorTextGS = 'Invalid numeric escape (expected fixed-width digits)'
                    break
                endif
                valueI = valueI * baseI + dI
            endfor
            if valueI > 255
                gErrorGI = 1
                gErrorTextGS = 'Numeric escape is outside byte range'
            endif
            MakeLeaf(1, valueI)
        elseif eS == 'D' or eS == 'w' or eS == 'W' or eS == 's' or eS == 'S'
            gErrorGI = 1
            gErrorTextGS = 'This escape is not in the supplied TSE help'
            MakeLeaf(1, 0)
        elseif eS == ''
            gErrorGI = 1
            gErrorTextGS = 'Trailing backslash'
            MakeLeaf(1, 0)
        else
            MakeLeaf(1, Asc(eS))
        endif
    elseif cS == ''
        MakeLeaf(8, 0) // empty epsilon
    else
        MakeLeaf(1, Asc(cS))
    endif
end

proc ParsePiece()
    string cS[2]
    integer sI, outsI, nI, pI
    ParseAtom()
    while gErrorGI == 0
        cS = Peek()
        if cS <> '*' and cS <> '+' and cS <> '@' and cS <> '#' and cS <> '?'
            break
        endif
        cS = Take()
        sI = gFragStartGI
        outsI = gFragOutGI
        nI = NewState(8, 0)  // split, with first edge ordered first
        if cS == '*'
            RxSet(3,nI,sI)
            PatchList(outsI, nI)
            gFragStartGI = nI
            gFragOutGI = NewPointer(nI, 1)
        elseif cS == '@'
            RxSet(2,nI,sI)
            PatchList(outsI, nI)
            gFragStartGI = nI
            gFragOutGI = NewPointer(nI, 2)
        elseif cS == '+'
            RxSet(3,nI,sI)
            PatchList(outsI, nI)
            gFragStartGI = sI
            gFragOutGI = NewPointer(nI, 1)
        elseif cS == '#'
            RxSet(2,nI,sI)
            PatchList(outsI, nI)
            gFragStartGI = sI
            gFragOutGI = NewPointer(nI, 2)
        else
            RxSet(2,nI,sI)
            gFragStartGI = nI
            pI = NewPointer(nI, 2)
            gFragOutGI = JoinLists(outsI, pI)
        endif
    endwhile
end

proc ParseConcat()
    integer sI, outsI
    string cS[2]
    if Peek() == '' or Peek() == '}' or Peek() == '|'
        MakeLeaf(8, 0)
        return()
    endif
    ParsePiece()
    sI = gFragStartGI
    outsI = gFragOutGI
    while gErrorGI == 0
        cS = Peek()
        if cS == '' or cS == '}' or cS == '|'
            break
        endif
        ParsePiece()
        PatchList(outsI, gFragStartGI)
        outsI = gFragOutGI
    endwhile
    gFragStartGI = sI
    gFragOutGI = outsI
end

proc ParseExpression()
    integer leftStartI, leftOutI, nI
    ParseConcat()
    leftStartI = gFragStartGI
    leftOutI = gFragOutGI
    while Peek() == '|' and gErrorGI == 0
        Take()
        ParseConcat()
        nI = NewState(8, 0)
        RxSet(2,nI,leftStartI)
        RxSet(3,nI,gFragStartGI)
        leftStartI = nI
        leftOutI = JoinLists(leftOutI, gFragOutGI)
    endwhile
    gFragStartGI = leftStartI
    gFragOutGI = leftOutI
end

integer proc CompileRegex()
    integer nI
    gStatesGI = 0
    gPointersGI = 0
    gPosGI = 1
    gErrorGI = 0
    gErrorTextGS = ''
    ParseExpression()
    if Peek() <> '' and gErrorGI == 0
        gErrorGI = 1
        gErrorTextGS = 'Unexpected character at pattern position ' + Str(gPosGI)
    endif
    if gErrorGI
        return(0)
    endif
    nI = NewState(9, 0)
    PatchList(gFragOutGI, nI)
    gRootGI = gFragStartGI
    return(not gErrorGI)
end

integer proc WordChar(integer cI)
    return((cI >= 65 and cI <= 90) or (cI >= 97 and cI <= 122) or (cI >= 48 and cI <= 57) or cI == 95)
end

integer proc EqualChar(integer aI, integer bI)
    if gIgnoreCaseGI
        if aI >= 65 and aI <= 90
            aI = aI + 32
        endif
        if bI >= 65 and bI <= 90
            bI = bI + 32
        endif
    endif
    return(aI == bI)
end

integer proc ClassMatches(integer stateI, integer chI)
    string payloadS[255], aS[2], bS[2]
    integer iI, loI, hiI, negateI, hitI
    payloadS = RxGetChars(stateI)
    negateI = 0
    hitI = 0
    iI = 1
    if SubStr(payloadS,1,1) == '~'
        negateI = 1
        iI = 2
    endif
    while iI <= Length(payloadS)
        aS = SubStr(payloadS,iI,1)
        loI = Asc(aS)
        hiI = loI
        if iI + 2 <= Length(payloadS) and SubStr(payloadS,iI+1,1) == '-'
            bS = SubStr(payloadS,iI+2,1)
            hiI = Asc(bS)
            iI = iI + 2
        endif
        if chI >= loI and chI <= hiI
            hitI = 1
        endif
        iI = iI + 1
    endwhile
    if negateI
        return(not hitI)
    endif
    return(hitI)
end

integer proc CharAt(integer lineI, integer colI)
    string cS[2]
    // In local mode, the NFA may never consume text beyond the block.
    if gLocalGI
        if not RxLocalPositionOK(lineI,colI)
            return(-1)
        endif
        // For column blocks, do not synthesize a newline after a
        // selected slice: the next line is not contiguous selected text.
        if gBlockTypeGI == _COLUMN_ and colI > gBlockLastColGI
            return(-1)
        endif
    endif
    if lineI > gLastLineGI
        return(-1)
    endif
    if lineI <> gCurLineGI
        GotoLine(lineI)
        gCurLineGI = lineI
        gLineLengthGI = CurrLineLen()
    endif
    if colI > gLineLengthGI
        if lineI < gLastLineGI
            return(10)
        endif
        return(-1)
    endif
    cS = GetText(colI, 1)
    if cS == ''
        return(-1)
    endif
    return(Asc(cS))
end

proc AddState(integer nodeI, integer lineI, integer colI, integer cursorTargetLineI, integer cursorTargetColI)
    integer chI, prevI, nextchI, boundaryI
    if nodeI == 0 or RxGet(8,nodeI) == gSeenSerialGI
        return()
    endif
    RxSet(8,nodeI,gSeenSerialGI)
    if RxGet(1,nodeI) == 8
        AddState(RxGet(2,nodeI), lineI, colI, cursorTargetLineI, cursorTargetColI)
        AddState(RxGet(3,nodeI), lineI, colI, cursorTargetLineI, cursorTargetColI)
    elseif RxGet(1,nodeI) == 4
        if colI == 1
            AddState(RxGet(2,nodeI), lineI, colI, cursorTargetLineI, cursorTargetColI)
        endif
    elseif RxGet(1,nodeI) == 5
        chI = CharAt(lineI,colI)
        if chI == 10 or chI == -1
            AddState(RxGet(2,nodeI), lineI, colI, cursorTargetLineI, cursorTargetColI)
        endif
    elseif RxGet(1,nodeI) == 10
        AddState(RxGet(2,nodeI), lineI, colI, lineI, colI)
    elseif RxGet(1,nodeI) == 6 or RxGet(1,nodeI) == 7
        prevI = -1
        if colI > 1
            prevI = CharAt(lineI,colI-1)
        endif
        nextchI = CharAt(lineI,colI)
        boundaryI = WordChar(prevI) <> WordChar(nextchI)
        if (RxGet(1,nodeI) == 6 and boundaryI) or (RxGet(1,nodeI) == 7 and not boundaryI)
            AddState(RxGet(2,nodeI),lineI,colI,cursorTargetLineI,cursorTargetColI)
        endif
    else
        gNActiveGI = gNActiveGI + 1
        if gNActiveGI <= MAX_STATES
            RxSet(9,gNActiveGI,nodeI)
            RxSet(10,nodeI,cursorTargetLineI)
            RxSet(11,nodeI,cursorTargetColI)
        endif
    endif
end

// Each active-state closure uses a serial stamp to avoid loops.
// Reset stamps periodically so a very long match never wraps the integer.
proc RxNextSeenSerial()
    integer stateIndexI
    if gSeenSerialGI >= 1000000
        for stateIndexI = 1 to gStatesGI
            RxSet(8,stateIndexI,0)
        endfor
        gSeenSerialGI = 0
    endif
    gSeenSerialGI = gSeenSerialGI + 1
end

integer proc MatchHere(integer firstLineI, integer firstColI)
    integer lineI, colI, chI, iI, nodeI, countI
    integer pendingFoundI, pendingLineI, pendingColI, pendingCursorLineI, pendingCursorColI
    pendingFoundI = 0
    lineI = firstLineI
    colI = firstColI
    RxNextSeenSerial()
    gNActiveGI = 0
    AddState(gRootGI,lineI,colI,0,0)
    // Continue until the regex accepts, no NFA states remain, or EOF.
    // There is deliberately no fixed maximum match length.
    while gNActiveGI > 0
        countI = gNActiveGI
        for iI = 1 to countI
            if RxGet(1,RxGet(9,iI)) == 9
                // Earlier active states have higher precedence. An accept at
                // index 1 wins immediately (lazy closure / first alternative).
                // An accept behind a still-live branch is provisional; the
                // earlier branch may subsequently yield a longer match.
                if iI == 1
                    gEndLineGI = lineI
                    gEndColGI = colI
                    gFoundCursorLineGI = RxGet(10,RxGet(9,iI))
                    gFoundCursorColGI = RxGet(11,RxGet(9,iI))
                    return(1)
                endif
                // Remember the latest provisional acceptance (greedy case).
                pendingFoundI = 1
                pendingLineI = lineI
                pendingColI = colI
                pendingCursorLineI = RxGet(10,RxGet(9,iI))
                pendingCursorColI = RxGet(11,RxGet(9,iI))
            endif
            RxSet(12,iI,RxGet(9,iI))
            RxSet(13,iI,RxGet(10,RxGet(12,iI)))
            RxSet(14,iI,RxGet(11,RxGet(12,iI)))
        endfor
        chI = CharAt(lineI,colI)
        if chI == -1
            if pendingFoundI
                gEndLineGI = pendingLineI
                gEndColGI = pendingColI
                gFoundCursorLineGI = pendingCursorLineI
                gFoundCursorColGI = pendingCursorColI
                return(1)
            endif
            return(0)
        endif
        if chI == 10
            lineI = lineI + 1
            colI = 1
        else
            colI = colI + 1
        endif
        RxNextSeenSerial()
        gNActiveGI = 0
        for iI = 1 to countI
            nodeI = RxGet(12,iI)
            if RxGet(1,nodeI) == 1 and (chI <> 10 or gMultilineGI) and EqualChar(RxGet(4,nodeI),chI)
                AddState(RxGet(2,nodeI),lineI,colI,RxGet(13,iI),RxGet(14,iI))
            elseif RxGet(1,nodeI) == 2 and chI <> 10
                AddState(RxGet(2,nodeI),lineI,colI,RxGet(13,iI),RxGet(14,iI))
            elseif RxGet(1,nodeI) == 11 and chI == 10 and lineI <= gLastLineGI
                AddState(RxGet(2,nodeI),lineI,colI,RxGet(13,iI),RxGet(14,iI))
            elseif RxGet(1,nodeI) == 3 and chI <> 10 and ClassMatches(nodeI,chI)
                AddState(RxGet(2,nodeI),lineI,colI,RxGet(13,iI),RxGet(14,iI))
            endif
        endfor
    endwhile
    if pendingFoundI
        gEndLineGI = pendingLineI
        gEndColGI = pendingColI
        gFoundCursorLineGI = pendingCursorLineI
        gFoundCursorColGI = pendingCursorColI
        return(1)
    endif
    return(0)
end

// A safe prefix is a sequence of literal characters at the very beginning
// of the expression.  Stop on any construct whose meaning is not trivially
// literal, including groups, classes, anchors and alternation.
// Quantified last literal is deliberately EXCLUDED from the prefix.
// This avoids skipping matches in expressions like abc?def and ab*cd.
// This intentionally sacrifices some acceleration to preserve correctness.
string proc RxMandatoryPrefix()
    string resultTextS[255], itemS[2], nextItemS[2]
    integer kI, patternLengthI, depthI, insideClassI, escapedI
    string scanCharS[2]
    resultTextS = ''
    patternLengthI = Length(gRegexGS)
    kI = 1
    // Any top-level alternation can match without this leading literal.
    // Ignore alternation inside tagged groups or character classes.
    depthI = 0
    insideClassI = 0
    escapedI = 0
    for kI = 1 to patternLengthI
        scanCharS = SubStr(gRegexGS,kI,1)
        if escapedI
            escapedI = 0
        elseif scanCharS == '\'
            escapedI = 1
        elseif scanCharS == '['
            insideClassI = 1
        elseif scanCharS == ']' and insideClassI
            insideClassI = 0
        elseif not insideClassI
            if scanCharS == '{'
                depthI = depthI + 1
            elseif scanCharS == '}'
                depthI = depthI - 1
            elseif scanCharS == '|' and depthI == 0
                return('')
            endif
        endif
    endfor
    kI = 1
    while kI <= patternLengthI
        itemS = SubStr(gRegexGS,kI,1)
        if itemS == '\' or itemS == '.' or itemS == '^' or itemS == '$' or itemS == '|' or itemS == '{' or itemS == '}' or itemS == '[' or itemS == ']' or itemS == '*' or itemS == '+' or itemS == '@' or itemS == '#' or itemS == '?'
            break
        endif
        nextItemS = ''
        if kI < patternLengthI
            nextItemS = SubStr(gRegexGS,kI+1,1)
        endif
        if nextItemS == '*' or nextItemS == '+' or nextItemS == '@' or nextItemS == '#' or nextItemS == '?'
            // Even a minimum-one closure may alter how much of the
            // literal should be consumed; exclude it for this version.
            break
        endif
        resultTextS = resultTextS + itemS
        kI = kI + 1
    endwhile
    return(resultTextS)
end

// Native compiled Find() returns candidate positions; only the full NFA
// determines whether a candidate is an actual regex match.
// Searches start at the beginning of this buffer, like the v0.0.0.6 scan.
integer proc RxFindNativePrefix(string prefixTextS)
    string nativeOptionsS[8]
    integer candidateLineI, candidateColI
    gLastLineGI = NumLines()
    gCurLineGI = -1
    gSeenSerialGI = 0
    gCandidateCountGI = 0
    nativeOptionsS = ''
    if gIgnoreCaseGI
        nativeOptionsS = 'i'
    endif
    if gLocalGI
        nativeOptionsS = nativeOptionsS + 'l'
    endif
    if gViewActiveGI
        GotoLine(gViewResumeLineGI)
        GotoPos(gViewResumeColGI)
    else
        GotoLine(1)
        GotoPos(1)
    endif
    while Find(prefixTextS,nativeOptionsS)
        candidateLineI = CurrLine()
        candidateColI = CurrPos()
        gCandidateCountGI = gCandidateCountGI + 1
        // Prevent repeated Find() from returning the same prefix.
        // On a failure the matcher may have navigated far away.
        if MatchHere(candidateLineI,candidateColI)
            if RxLocalSpanOK(candidateLineI,candidateColI,gEndLineGI,gEndColGI)
                gMatchLineGI = candidateLineI
                gMatchColGI = candidateColI
                return(1)
            endif
        endif
        GotoLine(candidateLineI)
        GotoPos(candidateColI)
        nativeOptionsS = '+'
        if gIgnoreCaseGI
            nativeOptionsS = 'i+'
        endif
        if gLocalGI
            nativeOptionsS = nativeOptionsS + 'l'
        endif
    endwhile
    return(0)
end

// Decode a literal segment for the native endpoint fast path.
// Only escaped regex punctuation is allowed, including \\ and \+.
// Escapes with TSE control semantics (\n, \t, \xnn, etc.) are declined.
integer proc RxDecodeEndpoint(string rawTextS)
    integer posIndexI
    string currentCharS[2], escapedCharS[2]
    gDecodedEndpointGS = ''
    posIndexI = 1
    while posIndexI <= Length(rawTextS)
        currentCharS = SubStr(rawTextS,posIndexI,1)
        if currentCharS == '\'
            if posIndexI >= Length(rawTextS)
                return(0)
            endif
            escapedCharS = SubStr(rawTextS,posIndexI+1,1)
            if Pos(escapedCharS, '.^$|?[]-~*+@#{}\') == 0
                return(0)
            endif
            gDecodedEndpointGS = gDecodedEndpointGS + escapedCharS
            posIndexI = posIndexI + 2
        else
            if Pos(currentCharS, '.^$|?[]*+@#{}') > 0
                return(0)
            endif
            gDecodedEndpointGS = gDecodedEndpointGS + currentCharS
            posIndexI = posIndexI + 1
        endif
    endwhile
    return(Length(gDecodedEndpointGS) > 0)
end

// Recognizes exactly: REQUIRED_LITERAL {. | \n } [* or @] REQUIRED_LITERAL
// (without spaces in the group). This particular gap matches ANY ordinary
// text and any number of line boundaries, so no SAL character scan is needed.
// No approximations are made for other regexes: those use the general matcher.
integer proc RxGetNativeEndpoints()
    integer jI, breakAtI, gapSizeI, totalLengthI
    string rawFirstS[255], rawLastS[255], opS[2], groupTextS[8]
    totalLengthI = Length(gRegexGS)
    groupTextS = '{.|\n}'
    gapSizeI = Length(groupTextS)
    breakAtI = 0
    for jI = 1 to totalLengthI - gapSizeI
        if SubStr(gRegexGS,jI,gapSizeI) == groupTextS
            if jI + gapSizeI <= totalLengthI
                opS = SubStr(gRegexGS,jI+gapSizeI,1)
                if opS == '*' or opS == '@'
                    if breakAtI <> 0
                        return(0)
                    endif
                    breakAtI = jI
                endif
            endif
        endif
    endfor
    if breakAtI <= 1 or breakAtI + gapSizeI >= totalLengthI
        return(0)
    endif
    rawFirstS = SubStr(gRegexGS,1,breakAtI-1)
    rawLastS = SubStr(gRegexGS,breakAtI+gapSizeI+1,totalLengthI-breakAtI-gapSizeI)
    if not RxDecodeEndpoint(rawFirstS)
        return(0)
    endif
    gFirstEndpointGS = gDecodedEndpointGS
    if not RxDecodeEndpoint(rawLastS)
        return(0)
    endif
    gLastEndpointGS = gDecodedEndpointGS
    gWantMaximumGI = (SubStr(gRegexGS,breakAtI+gapSizeI,1) == '@')
    return(1)
end

// Two native text searches avoid interpreting millions of intervening bytes.
// In the universal gap form any suffix following the prefix is valid.
integer proc RxFindNativeEndpoints(string firstLiteralS, string lastLiteralS, integer wantMaximumI)
    string optionsTextS[8]
    integer firstLineI, firstColI, lastLineI, lastColI, bestLineI, bestColI
    integer endColI, endLineI
    optionsTextS = ''
    if gIgnoreCaseGI
        optionsTextS = 'i'
    endif
    if gLocalGI
        optionsTextS = optionsTextS + 'l'
    endif
    RxLog('NATIVE: total lines=' + Str(NumLines()))
    gLastLineGI = NumLines()
    if gViewActiveGI
        GotoLine(gViewResumeLineGI)
        GotoPos(gViewResumeColGI)
    else
        GotoLine(1)
        GotoPos(1)
    endif
    RxLog('NATIVE: first Find START')
    if not Find(firstLiteralS,optionsTextS)
        RxLog('NATIVE: first Find FAILED')
        return(0)
    endif
    firstLineI = CurrLine()
    firstColI = CurrPos()
    RxLog('NATIVE: first Find FOUND at ' + Str(firstLineI) + ':' + Str(firstColI))
    // Start searching after the initial required literal.
    GotoLine(firstLineI)
    GotoPos(firstColI + Length(firstLiteralS))
    RxLog('NATIVE: second Find START from ' + Str(CurrLine()) + ':' + Str(CurrPos()))
    if not Find(lastLiteralS,optionsTextS)
        RxLog('NATIVE: second Find FAILED')
        return(0)
    endif
    bestLineI = CurrLine()
    bestColI = CurrPos()
    RxLog('NATIVE: second Find FOUND at ' + Str(bestLineI) + ':' + Str(bestColI))
    if wantMaximumI
        RxLog('NATIVE: maximum closure suffix search START')
        // Maximum closure chooses the last reachable suffix occurrence.
        // Native Find is still used for every occurrence; no SAL text scan.
        while Find(lastLiteralS,'+' + optionsTextS)
            if CurrLine() == bestLineI and CurrPos() == bestColI
                break
            endif
            bestLineI = CurrLine()
            bestColI = CurrPos()
        endwhile
    endif
    if wantMaximumI
        RxLog('NATIVE: maximum closure suffix search DONE')
    endif
    endLineI = bestLineI
    endColI = bestColI + Length(lastLiteralS)
    gMatchLineGI = firstLineI
    gMatchColGI = firstColI
    gEndLineGI = endLineI
    gEndColGI = endColI
    gFoundCursorLineGI = 0
    gFoundCursorColGI = 0
    if not RxLocalSpanOK(gMatchLineGI,gMatchColGI,gEndLineGI,gEndColGI)
        return(0)
    endif
    return(1)
end

integer proc RxFindFirstMatch()
    integer lineI, colI, lenI
    string prefixTextS[255]
    if gMultilineGI and (not gLocalGI or gBlockTypeGI <> _COLUMN_) and RxGetNativeEndpoints()
        gSearchPathGS = 'NATIVE TWO ENDPOINTS'
        RxLog('PATH: NATIVE TWO ENDPOINTS')
        RxLog('First endpoint: ' + gFirstEndpointGS)
        RxLog('Last endpoint: ' + gLastEndpointGS)
        if gWantMaximumGI
            RxLog('Closure: MAXIMUM (@)')
        else
            RxLog('Closure: MINIMUM (*)')
        endif
        return(RxFindNativeEndpoints(gFirstEndpointGS,gLastEndpointGS,gWantMaximumGI))
    endif
    RxLog('Two-endpoint pattern NOT recognized')
    prefixTextS = RxMandatoryPrefix()
    if prefixTextS <> ''
        gSearchPathGS = 'NATIVE PREFIX + NFA'
        RxLog('PATH: NATIVE PREFIX with SAL NFA verification')
        RxLog('Prefix: ' + prefixTextS)
        return(RxFindNativePrefix(prefixTextS))
    endif
    gSearchPathGS = 'FULL SAL NFA'
    RxLog('PATH: SLOW FULL SAL NFA from every position')
    gCurLineGI = -1
    gSeenSerialGI = 0
    gLastLineGI = NumLines()
    for lineI = 1 to gLastLineGI
        if (not gViewActiveGI or lineI >= gViewResumeLineGI) and (not gLocalGI or (lineI >= gBlockFirstLineGI and lineI <= gBlockLastLineGI))
            GotoLine(lineI)
            lenI = CurrLineLen()
            gCurLineGI = lineI
            gLineLengthGI = lenI
            for colI = 1 to lenI + 1
                if not gViewActiveGI or lineI <> gViewResumeLineGI or colI >= gViewResumeColGI
                    if RxLocalPositionOK(lineI,colI) and MatchHere(lineI,colI)
                        if RxLocalSpanOK(lineI,colI,gEndLineGI,gEndColGI)
                            gMatchLineGI = lineI
                            gMatchColGI = colI
                            return(1)
                        endif
                    endif
                endif
            endfor
        endif
    endfor
    return(0)
end


// Option a: search all ordinary (non-hidden, non-system) files in the
// editor ring.  NumFiles() excludes the hidden integer-storage buffer.
// Search begins in the user's current file, then proceeds via NextFile().
// A successful search leaves the matching file selected; a failure restores
// the original buffer and cursor.  No marks or file contents are changed.
integer proc RxFindRingMatch()
    integer initialBufferI, initialLineI, initialColI
    integer fileCountI, fileIndexI
    initialBufferI = GetBufferId()
    initialLineI = CurrLine()
    initialColI = CurrPos()
    fileCountI = NumFiles()
    if fileCountI < 1
        RxLog('RING: no searchable files')
        return(0)
    endif
    RxLog('RING: beginning a search in ' + Str(fileCountI) + ' files')
    for fileIndexI = 1 to fileCountI
        // As each native prefix/endpoint search starts at the buffer beginning,
        // this also makes zero-length and anchored expressions deterministic.
        GotoLine(1)
        GotoPos(1)
        RxLog('RING: searching file ' + Str(fileIndexI) + '/' + Str(fileCountI) +
              ' buffer=' + Str(GetBufferId()))
        gFoundCursorLineGI = 0
        gFoundCursorColGI = 0
        gCandidateCountGI = 0
        if RxFindFirstMatch()
            RxLog('RING: match in buffer=' + Str(GetBufferId()))
            return(1)
        endif
        if fileIndexI < fileCountI
            NextFile()
        endif
    endfor
    GotoBufferId(initialBufferI)
    GotoLine(initialLineI)
    GotoPos(initialColI)
    RxLog('RING: no match; original file/cursor restored')
    return(0)
end



// Compact source-context preview. The start line includes preceding text;
// multi-line results additionally show context around the end position.
// This reads only the two endpoint lines (never scans the match span).
string proc RxViewContextPreview(integer firstLineI, integer firstColI,
                                 integer lastLineI, integer lastColI)
    integer leftColI, lineLengthI, takeI, prefixI, visibleFirstI, visibleLastI
    string firstPartS[96], lastPartS[96], resultS[192]
    gViewMark1FirstGI = 0
    gViewMark1LastGI = 0
    gViewMark2FirstGI = 0
    gViewMark2LastGI = 0
    GotoLine(firstLineI)
    lineLengthI = CurrLineLen()
    leftColI = firstColI - 20
    if leftColI < 1
        leftColI = 1
    endif
    takeI = lineLengthI - leftColI + 1
    if takeI > 48
        takeI = 48
    endif
    if takeI > 0
        firstPartS = GetText(leftColI,takeI)
    else
        firstPartS = '[empty line]'
    endif
    prefixI = 0
    if leftColI > 1
        firstPartS = '...' + firstPartS
        prefixI = 3
    endif
    visibleFirstI = firstColI - leftColI + prefixI + 1
    visibleLastI = prefixI + takeI
    if firstLineI == lastLineI
        visibleLastI = lastColI - leftColI + prefixI
    endif
    if visibleFirstI < 1
        visibleFirstI = 1
    endif
    if visibleLastI > prefixI + takeI
        visibleLastI = prefixI + takeI
    endif
    if visibleFirstI <= visibleLastI
        gViewMark1FirstGI = visibleFirstI
        gViewMark1LastGI = visibleLastI
    endif
    if firstLineI == lastLineI
        if leftColI + takeI <= lineLengthI
            firstPartS = firstPartS + '...'
        endif
        return(firstPartS)
    endif
    GotoLine(lastLineI)
    lineLengthI = CurrLineLen()
    leftColI = lastColI - 36
    if leftColI < 1
        leftColI = 1
    endif
    takeI = lineLengthI - leftColI + 1
    if takeI > 48
        takeI = 48
    endif
    if takeI > 0
        lastPartS = GetText(leftColI,takeI)
    else
        lastPartS = '[empty line]'
    endif
    prefixI = 0
    if leftColI > 1
        lastPartS = '...' + lastPartS
        prefixI = 3
    endif
    // In the last line, the matched portion ends just before lastColI.
    visibleLastI = lastColI - leftColI + prefixI
    if visibleLastI > prefixI + takeI
        visibleLastI = prefixI + takeI
    endif
    if visibleLastI >= prefixI + 1
        gViewMark2FirstGI = Length(firstPartS) + 5 + prefixI + 1
        gViewMark2LastGI = Length(firstPartS) + 5 + visibleLastI
    endif
    if leftColI + takeI <= lineLengthI
        lastPartS = lastPartS + '...'
    endif
    resultS = firstPartS + ' ... ' + lastPartS
    return(resultS)
end

// View (v): repeat the same engine searches from the prior match end.
// Each result records its source buffer ID and cursor coordinates in
// the private results buffer; its line text is a short context preview.
// A bounded list protects TSE from enormous result enumerations.
integer proc RxViewStepForward(integer matchEndLineI, integer matchEndColI)
    integer textLengthI
    if matchEndLineI > NumLines()
        return(0)
    endif
    GotoLine(matchEndLineI)
    textLengthI = CurrLineLen()
    if matchEndColI <= textLengthI
        gViewResumeLineGI = matchEndLineI
        gViewResumeColGI = matchEndColI + 1
        return(1)
    endif
    if matchEndLineI < NumLines()
        gViewResumeLineGI = matchEndLineI + 1
        gViewResumeColGI = 1
        return(1)
    endif
    return(0)
end

proc RxCollectViewInCurrentFile()
    integer startLineI, startColI, destLineI, destColI, originalFileIdI
    integer resultLineI, prefixLengthI
    string descriptionS[255], previewS[192], keyS[32], prefixS[128]
    originalFileIdI = GetBufferId()
    gViewResumeLineGI = 1
    gViewResumeColGI = 1
    gViewActiveGI = 1
    while gViewResultCountGI < gViewMaxMatchesGI
        if not RxFindFirstMatch()
            break
        endif
        startLineI = gMatchLineGI
        startColI = gMatchColGI
        destLineI = gEndLineGI
        destColI = gEndColGI
        // Get context without scanning intervening lines (fast for huge spans).
        previewS = RxViewContextPreview(startLineI,startColI,destLineI,destColI)
        prefixS = SqueezePath(CurrFilename(),55) + '  ' +
                  Str(startLineI) + ':' + Str(startColI) + ' - ' +
                  Str(destLineI) + ':' + Str(destColI) + '  '
        prefixLengthI = Length(prefixS)
        descriptionS = prefixS + previewS
        GotoBufferId(gViewBufferGI)
        AddLine(descriptionS)
        resultLineI = CurrLine()
        keyS = Str(resultLineI)
        SetBufferInt('B'+keyS,originalFileIdI,gViewBufferGI)
        if gViewMark1FirstGI > 0
            SetBufferInt('H1'+keyS,prefixLengthI + gViewMark1FirstGI,gViewBufferGI)
            SetBufferInt('H2'+keyS,prefixLengthI + gViewMark1LastGI,gViewBufferGI)
        endif
        if gViewMark2FirstGI > 0
            SetBufferInt('H3'+keyS,prefixLengthI + gViewMark2FirstGI,gViewBufferGI)
            SetBufferInt('H4'+keyS,prefixLengthI + gViewMark2LastGI,gViewBufferGI)
        endif
        if gFoundCursorLineGI > 0
            SetBufferInt('L'+keyS,gFoundCursorLineGI,gViewBufferGI)
            SetBufferInt('C'+keyS,gFoundCursorColGI,gViewBufferGI)
        else
            SetBufferInt('L'+keyS,startLineI,gViewBufferGI)
            SetBufferInt('C'+keyS,startColI,gViewBufferGI)
        endif
        GotoBufferId(originalFileIdI)
        gViewResultCountGI = gViewResultCountGI + 1
        // Consume nonoverlapping matches. Empty matches MUST advance.
        if startLineI == destLineI and startColI == destColI
            if not RxViewStepForward(destLineI,destColI)
                break
            endif
        else
            gViewResumeLineGI = destLineI
            gViewResumeColGI = destColI
            if gViewResumeLineGI > NumLines()
                break
            endif
        endif
    endwhile
    gViewActiveGI = 0
end

// User-defined TSE list display hook: draw all text normally but highlight
// the exact visible portions of each match.  This does NOT modify the buffer,
// the regular expression, or the original source file syntax highlighting.
// TSE 4.50.33 supports HookDisplay() while List() is active.
proc RxViewPaintLine(integer currentLineB)
    integer listLineI, jI, textLengthI, previousAttrI, normalAttrI
    integer mark1FirstI, mark1LastI, mark2FirstI, mark2LastI, lineWidthI
    string rowTextS[255], indexS[32]
    if not gViewPaintEnabledGI or GetBufferId() <> gViewBufferGI
        return()
    endif
    listLineI = CurrLine()
    if listLineI < 1
        return()
    endif
    indexS = Str(listLineI)
    rowTextS = GetText(1,255)
    textLengthI = Length(rowTextS)
    mark1FirstI = GetBufferInt('H1'+indexS,gViewBufferGI)
    mark1LastI = GetBufferInt('H2'+indexS,gViewBufferGI)
    mark2FirstI = GetBufferInt('H3'+indexS,gViewBufferGI)
    mark2LastI = GetBufferInt('H4'+indexS,gViewBufferGI)
    previousAttrI = Query(Attr)
    normalAttrI = Query(TextAttr)
    if currentLineB
        normalAttrI = Query(CursorAttr)
    endif
    lineWidthI = Query(ScreenCols)
    if textLengthI > lineWidthI
        textLengthI = lineWidthI
    endif
    for jI = 1 to textLengthI
        if (jI >= mark1FirstI and jI <= mark1LastI and mark1FirstI > 0) or
           (jI >= mark2FirstI and jI <= mark2LastI and mark2FirstI > 0)
            Set(Attr,Query(HiLiteAttr))
        else
            Set(Attr,normalAttrI)
        endif
        PutChar(SubStr(rowTextS,jI,1))
    endfor
    Set(Attr,normalAttrI)
    ClrEol()
    Set(Attr,previousAttrI)
end

// The list can be opened again after viewing a selected source location.
// Press Escape in the list to finish. The source is not modified.
proc RxPresentViewResults(integer originalFileIdI)
    integer chosenLineI, sourceIdI, sourceLineI, sourceColI, selectedI
    string keyS[32]
    if gViewResultCountGI == 0
        GotoBufferId(originalFileIdI)
        Warn('No match found')
        return()
    endif
    GotoBufferId(gViewBufferGI)
    GotoLine(1)
    loop
        gViewPaintEnabledGI = 1
        HookDisplay(RxViewPaintLine,,,)
        selectedI = List('REGEXENGINE: '+Str(gViewResultCountGI)+' matches',Query(ScreenCols)-4)
        UnhookDisplay()
        gViewPaintEnabledGI = 0
        if not selectedI
            break
        endif
        chosenLineI = CurrLine()
        keyS = Str(chosenLineI)
        sourceIdI = GetBufferInt('B'+keyS,gViewBufferGI)
        sourceLineI = GetBufferInt('L'+keyS,gViewBufferGI)
        sourceColI = GetBufferInt('C'+keyS,gViewBufferGI)
        if sourceIdI <> 0 and sourceLineI > 0
            GotoBufferId(sourceIdI)
            GotoLine(sourceLineI)
            GotoPos(sourceColI)
            Warn('Match at ',Str(sourceLineI),':',Str(sourceColI),
                 '  OK: return to results; Escape in list: finish')
        endif
        GotoBufferId(gViewBufferGI)
        GotoLine(chosenLineI)
    endloop
    GotoBufferId(originalFileIdI)
end

proc RxRunViewSearch()
    integer initialFileIdI, initialLineI, initialColI
    integer fileCountI, fileIndexI
    initialFileIdI = GetBufferId()
    initialLineI = CurrLine()
    initialColI = CurrPos()
    gViewBufferGI = CreateTempBuffer()
    if gViewBufferGI == 0
        Warn('Unable to create REGEXENGINE results buffer')
        return()
    endif
    GotoBufferId(initialFileIdI)
    gViewResultCountGI = 0
    gViewMaxMatchesGI = GetProfileInt('View','MaxResults',2000,gIniGS)
    if gViewMaxMatchesGI < 1
        gViewMaxMatchesGI = 2000
    endif
    fileCountI = 1
    if gAllFilesGI
        fileCountI = NumFiles()
    endif
    for fileIndexI = 1 to fileCountI
        RxLog('VIEW: scanning file '+Str(fileIndexI)+'/'+Str(fileCountI))
        RxCollectViewInCurrentFile()
        if gViewResultCountGI >= gViewMaxMatchesGI
            break
        endif
        if fileIndexI < fileCountI
            NextFile()
        endif
    endfor
    GotoBufferId(initialFileIdI)
    GotoLine(initialLineI)
    GotoPos(initialColI)
    RxPresentViewResults(initialFileIdI)
end

#include ["regexengine_test.inc"]

proc Main()
    string patternS[255], optionsS[32], macrodirS[255]
    integer iI
    gSourceBufferGI = GetBufferId()
    // Derive full directory from actual compiled macro, never CurrDir().
    macrodirS = CurrMacroFilename()
    iI = RPos(Chr(92), macrodirS)
    if iI == 0
        iI = RPos('/',macrodirS)
    endif
    if iI > 0
        macrodirS = SubStr(macrodirS, 1, iI)
    else
        Warn('Cannot locate compiled macro directory: ', macrodirS)
        return()
    endif
    gLocalGI = 0
    gAllFilesGI = 0
    gViewGI = 0
    gViewActiveGI = 0
    gViewPaintEnabledGI = 0
    gIniGS = macrodirS + 'regexengine.ini'
    gLogFileGS = macrodirS + 'regexengine.log'
    gStoreBufferGI = CreateTempBuffer()
    if gStoreBufferGI == 0
        Warn('Unable to allocate REGEXENGINE storage')
        return()
    endif
    GotoBufferId(gSourceBufferGI)
    if GetProfileInt('Tests','RunTests',0,gIniGS)
        RxRunAllTests(macrodirS)
        GotoBufferId(gSourceBufferGI)
        return()
    endif
    patternS = GetProfileStr('Search','Pattern','{procedure}.*\n.*integer',gIniGS)
    optionsS = GetProfileStr('Search','Options','im',gIniGS)
    if not Ask('TSE regex (\\n = newline):',patternS,HISTORY_REGEX)
        return()
    endif
    if not Ask('Options (a=all files, i=ignore case, l=local, m=multiline, v=view):',optionsS,HISTORY_REGEX + 1)
        return()
    endif
    WriteProfileStr('Search','Pattern',patternS,gIniGS)
    WriteProfileStr('Search','Options',optionsS,gIniGS)
    gIgnoreCaseGI = Pos('i',Lower(optionsS)) > 0
    gMultilineGI = Pos('m',Lower(optionsS)) > 0
    gLocalGI = Pos('l',Lower(optionsS)) > 0
    gAllFilesGI = Pos('a',Lower(optionsS)) > 0
    gViewGI = Pos('v',Lower(optionsS)) > 0
    if gAllFilesGI and gLocalGI
        Warn('Options a (all files) and l (marked block) cannot be combined')
        return()
    endif
    if gLocalGI
        gBlockTypeGI = isBlockInCurrFile()
        if gBlockTypeGI == 0
            Warn('Option l requires a marked block in the current file')
            return()
        endif
        gBlockFirstLineGI = Query(BlockBegLine)
        gBlockLastLineGI = Query(BlockEndLine)
        gBlockFirstColGI = Query(BlockBegCol)
        gBlockLastColGI = Query(BlockEndCol)
    endif
    gRegexGS = patternS
    RxLogStart(patternS,optionsS)
    gFoundCursorLineGI = 0
    gFoundCursorColGI = 0
    gCandidateCountGI = 0
    RxLog('COMPILE BEGIN')
    if not CompileRegex()
        RxLog('COMPILE FAILED: ' + gErrorTextGS)
        Warn('Regex compile error: ',gErrorTextGS)
        return()
    endif
    RxLog('COMPILE OK states=' + Str(gStatesGI))
    RxLog('SEARCH BEGIN')
    if gViewGI
        RxRunViewSearch()
        return()
    endif
    if gAllFilesGI
        iI = RxFindRingMatch()
    else
        PushPosition()
        iI = RxFindFirstMatch()
        PopPosition()
    endif
    if iI
        RxLog('MATCH FOUND ' + Str(gMatchLineGI) + ':' + Str(gMatchColGI) + ' - ' + Str(gEndLineGI) + ':' + Str(gEndColGI))
        if gFoundCursorLineGI > 0
            GotoLine(gFoundCursorLineGI)
            GotoPos(gFoundCursorColGI)
        else
            GotoLine(gMatchLineGI)
            GotoPos(gMatchColGI)
        endif
        Warn('Match: ',Str(gMatchLineGI),':',Str(gMatchColGI),' - ',Str(gEndLineGI),':',Str(gEndColGI))
    else
        RxLog('SEARCH COMPLETED: NO MATCH')
        Warn('No match found')
    endif
end
