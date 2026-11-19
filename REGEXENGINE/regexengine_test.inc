// REGEXENGINE automated regression runner 1.0.0.0.23.
// Included by regexengine.s after the matching procedures.
// Keeps existing matching engine untouched. No external dependencies.
integer gTestTotalGI, gTestPassedGI, gTestFailedGI, gTestSkippedGI
string gTestReportGS[255], gTestFolderGS[255]

proc RxTestReport(string messageS)
    integer handleI, bytesI
    handleI = fOpen(gTestReportGS, _OPEN_WRITEONLY_ | _OPEN_DENYNONE_)
    if handleI == -1
        return()
    endif
    fSeek(handleI,0,_SEEK_END_)
    bytesI = fWrite(handleI,messageS + Chr(13) + Chr(10))
    fClose(handleI)
end

// Zero expected coordinates mean that coordinate is not tested.
// Every case verifies successful compilation and exact found/not-found status.
// Expected end and cursor may be specified for more precise checks.
proc RxRunTestCase(string fixtureS, string expressionS, string optionsS,
                   integer expectedFoundI, integer expectedLineI,
                   integer expectedColI, integer expectedEndLineI,
                   integer expectedEndColI, integer expectedCursorLineI,
                   integer expectedCursorColI)
    integer fixtureBufferI, foundI, passedI, originalBufferI
    string detailS[255], filePathS[255]
    originalBufferI = GetBufferId()
    gTestTotalGI = gTestTotalGI + 1
    filePathS = gTestFolderGS + fixtureS
    fixtureBufferI = EditBuffer(filePathS, _HIDDEN_)
    if fixtureBufferI == 0
        gTestFailedGI = gTestFailedGI + 1
        RxTestReport('FAIL | ' + fixtureS + ' | could not load fixture')
        GotoBufferId(originalBufferI)
        return()
    endif
    gRegexGS = expressionS
    gIgnoreCaseGI = Pos('i',Lower(optionsS)) > 0
    gMultilineGI = Pos('m',Lower(optionsS)) > 0
    gFoundCursorLineGI = 0
    gFoundCursorColGI = 0
    gMatchLineGI = 0
    gMatchColGI = 0
    gEndLineGI = 0
    gEndColGI = 0
    passedI = 1
    gSearchPathGS = 'NOT STARTED'
    gCandidateCountGI = 0
    detailS = ''
    if not CompileRegex()
        passedI = 0
        detailS = 'COMPILE ERROR: ' + gErrorTextGS
    else
        foundI = RxFindFirstMatch()
        if foundI <> expectedFoundI
            passedI = 0
            detailS = 'found=' + Str(foundI) + ' expected=' + Str(expectedFoundI)
        elseif foundI
            if expectedLineI > 0 and (gMatchLineGI <> expectedLineI or gMatchColGI <> expectedColI)
                passedI = 0
                detailS = 'start=' + Str(gMatchLineGI) + ':' + Str(gMatchColGI) + ' expected=' + Str(expectedLineI) + ':' + Str(expectedColI)
            endif
            if expectedEndLineI > 0 and (gEndLineGI <> expectedEndLineI or gEndColGI <> expectedEndColI)
                passedI = 0
                detailS = 'end=' + Str(gEndLineGI) + ':' + Str(gEndColGI) + ' expected=' + Str(expectedEndLineI) + ':' + Str(expectedEndColI)
            endif
            if expectedCursorLineI > 0 and (gFoundCursorLineGI <> expectedCursorLineI or gFoundCursorColGI <> expectedCursorColI)
                passedI = 0
                detailS = 'cursor=' + Str(gFoundCursorLineGI) + ':' + Str(gFoundCursorColGI) + ' expected=' + Str(expectedCursorLineI) + ':' + Str(expectedCursorColI)
            endif
        endif
    endif
    if passedI
        gTestPassedGI = gTestPassedGI + 1
        RxTestReport('PASS | ' + fixtureS + ' | ' + expressionS)
    else
        gTestFailedGI = gTestFailedGI + 1
        RxTestReport('FAIL | ' + fixtureS + ' | ' + expressionS)
        RxTestReport('       ' + detailS)
        RxTestReport('       path=' + gSearchPathGS + ' states=' + Str(gStatesGI) + ' candidates=' + Str(gCandidateCountGI))
    endif
    GotoBufferId(fixtureBufferI)
    AbandonFile()
    GotoBufferId(originalBufferI)
end


// Parser-rejection checks: these cases PASS only when CompileRegex() rejects
// a deliberately malformed expression. They do not run the matching engine.
proc RxRunRejectTest(string fixtureS, string expressionS, string optionsS)
    integer fixtureBufferI, originalBufferI, compileSucceededI
    originalBufferI = GetBufferId()
    gTestTotalGI = gTestTotalGI + 1
    fixtureBufferI = EditBuffer(gTestFolderGS + fixtureS, _HIDDEN_)
    if fixtureBufferI == 0
        gTestFailedGI = gTestFailedGI + 1
        RxTestReport('FAIL | ' + fixtureS + ' | could not load fixture')
        GotoBufferId(originalBufferI)
        return()
    endif
    gRegexGS = expressionS
    gIgnoreCaseGI = Pos('i',Lower(optionsS)) > 0
    gMultilineGI = Pos('m',Lower(optionsS)) > 0
    compileSucceededI = CompileRegex()
    if compileSucceededI
        gTestFailedGI = gTestFailedGI + 1
        RxTestReport('FAIL | ' + fixtureS + ' | ' + expressionS + ' | unexpectedly compiled')
    else
        gTestPassedGI = gTestPassedGI + 1
        RxTestReport('PASS | ' + fixtureS + ' | rejects ' + expressionS)
    endif
    GotoBufferId(fixtureBufferI)
    AbandonFile()
    GotoBufferId(originalBufferI)
end


// Controlled boundary checks for Local mode. These tests validate the
// SAME RxLocalPositionOK() / RxLocalSpanOK() predicates called by matching.
// They simulate the selection coordinates; they do NOT create a TSE mark and
// therefore do NOT verify Find(...,'l') or Query(BlockBegLine) integration.
proc RxRunLocalBoundaryCase(string labelS, integer blockTypeI,
                            integer firstLineI, integer firstColI,
                            integer lastLineI, integer lastColI,
                            integer queryStartLineI, integer queryStartColI,
                            integer queryEndLineI, integer queryEndColI,
                            integer expectedI)
    integer actualI
    gTestTotalGI = gTestTotalGI + 1
    gLocalGI = 1
    gBlockTypeGI = blockTypeI
    gBlockFirstLineGI = firstLineI
    gBlockFirstColGI = firstColI
    gBlockLastLineGI = lastLineI
    gBlockLastColGI = lastColI
    actualI = RxLocalSpanOK(queryStartLineI,queryStartColI,queryEndLineI,queryEndColI)
    if actualI == expectedI
        gTestPassedGI = gTestPassedGI + 1
        RxTestReport('PASS | LOCAL BOUNDS | ' + labelS)
    else
        gTestFailedGI = gTestFailedGI + 1
        RxTestReport('FAIL | LOCAL BOUNDS | ' + labelS)
        RxTestReport('       actual=' + Str(actualI) + ' expected=' + Str(expectedI))
    endif
    gLocalGI = 0
end

proc RxRunLocalBoundaryTests()
    RxTestReport('')
    RxTestReport('--- LOCAL BOUNDARY PREDICATES (SYNTHETIC SELECTIONS) ---')
    // Every test uses start and exclusive end coordinates.
    RxRunLocalBoundaryCase('line block: inside',_LINE_,3,1,5,30,3,1,5,31,1)
    RxRunLocalBoundaryCase('line block: before',_LINE_,3,1,5,30,2,1,4,4,0)
    RxRunLocalBoundaryCase('line block: beyond last line',_LINE_,3,1,5,30,4,1,6,1,0)
    RxRunLocalBoundaryCase('line block: multi-line inside',_LINE_,3,1,5,30,3,10,5,2,1)
    RxRunLocalBoundaryCase('inclusive character block: start before selection',_INCLUSIVE_,3,4,5,8,3,3,4,2,0)
    RxRunLocalBoundaryCase('inclusive character block: at start',_INCLUSIVE_,3,4,5,8,3,4,4,2,1)
    RxRunLocalBoundaryCase('inclusive character block: last exclusive position',_INCLUSIVE_,3,4,5,8,4,2,5,9,1)
    RxRunLocalBoundaryCase('inclusive character block: past last position',_INCLUSIVE_,3,4,5,8,4,2,5,10,0)
    RxRunLocalBoundaryCase('noninclusive character block: at last position',_NONINCLUSIVE_,3,4,5,8,4,2,5,8,1)
    RxRunLocalBoundaryCase('noninclusive character block: past last position',_NONINCLUSIVE_,3,4,5,8,4,2,5,9,0)
    RxRunLocalBoundaryCase('column block: single-line inside',_COLUMN_,3,4,5,8,4,4,4,9,1)
    RxRunLocalBoundaryCase('column block: left of selection',_COLUMN_,3,4,5,8,4,3,4,7,0)
    RxRunLocalBoundaryCase('column block: right of selection',_COLUMN_,3,4,5,8,4,5,4,10,0)
    RxRunLocalBoundaryCase('column block: cannot span lines',_COLUMN_,3,4,5,8,3,4,4,8,0)
    RxRunLocalBoundaryCase('column block: outside selected lines',_COLUMN_,3,4,5,8,2,4,2,8,0)
    // Explicitly ensure disabling Local mode removes all block bounds.
    gLocalGI = 0
    gTestTotalGI = gTestTotalGI + 1
    if RxLocalSpanOK(1,1,100,250)
        gTestPassedGI = gTestPassedGI + 1
        RxTestReport('PASS | LOCAL BOUNDS | option off permits unrestricted span')
    else
        gTestFailedGI = gTestFailedGI + 1
        RxTestReport('FAIL | LOCAL BOUNDS | option off permits unrestricted span')
    endif
end

proc RxRunAllTests(string macroFolderS)
    integer reportHandleI, originalBufferI, previousLogEnabledI
    originalBufferI = GetBufferId()
    previousLogEnabledI = gLogEnabledGI
    gLocalGI = 0
    gLogEnabledGI = 0
    gTestTotalGI = 0
    gTestPassedGI = 0
    gTestFailedGI = 0
    gTestSkippedGI = 0
    gTestFolderGS = macroFolderS + 'tests' + Chr(92)
    gTestReportGS = macroFolderS + 'regexengine_test_report.txt'
    reportHandleI = fCreate(gTestReportGS)
    if reportHandleI == -1
        Warn('Cannot create test report: ',gTestReportGS)
        return()
    endif
    fClose(reportHandleI)
    RxTestReport('REGEXENGINE AUTOMATED REGRESSION TESTS v1.0.0.0.23')
    RxTestReport('Engine release: 1.0.0.0.23; native endpoint optimization preserved')
    RxTestReport('')
    RxRunTestCase('01_literal.txt','Ampersand','im',1,2,1,0,0,0,0)
    RxRunTestCase('02_multiline_consecutive.txt','first\nsecond','im',1,1,1,0,0,0,0)
    RxRunTestCase('03_multiline_blanks.txt','first{\n}@second','im',1,1,1,0,0,0,0)
    RxRunTestCase('04_multiline_nonempty.txt','Ampersand{.|\n}*manager','im',1,1,1,0,0,0,0)
    RxRunTestCase('04_multiline_nonempty.txt','Ampersand.*{\n}@.*manager','im',0,0,0,0,0,0,0)
    RxRunTestCase('05_case_and_classes.txt','[A-Z]#','im',1,2,1,0,0,0,0)
    RxRunTestCase('06_closure.txt','ab*','im',1,1,1,1,2,0,0)
    RxRunTestCase('06_closure.txt','ab@','im',1,1,1,1,5,0,0)
    RxRunTestCase('07_alternation.txt','{whatever}|{what}','im',1,1,1,1,9,0,0)
    RxRunTestCase('08_cursor.txt','Hello \cWorld!','im',1,1,1,1,13,1,7)
    RxRunTestCase('09_endpoint_minmax.txt','Ampersand{.|\n}*manager','im',1,1,1,1,20,0,0)
    RxRunTestCase('09_endpoint_minmax.txt','Ampersand{.|\n}@manager','im',1,1,1,1,30,0,0)
    RxRunTestCase('10_prefix_before_suffix.txt','Ampersand{.|\n}*manager','im',1,1,1,0,0,0,0)
    RxRunTestCase('11_missing_suffix.txt','Ampersand{.|\n}*manager','im',0,0,0,0,0,0,0)
    RxRunTestCase('12_escaped_plus.txt','010     \+ Java{.|\n}*1,114,486,798','im',1,1,1,0,0,0,0)
    RxRunTestCase('13_empty_and_anchor.txt','^$','im',1,1,1,0,0,0,0)
    RxRunTestCase('14_long_span.txt','Ampersand{.|\n}*manager','im',1,1,1,0,0,0,0)
    RxTestReport('--- EXTENDED TSE OPERATOR COMPATIBILITY ---')
    RxRunTestCase('15_class_ranges.txt','[A-Z]#','im',1,1,1,1,2,0,0)
    RxRunTestCase('15_class_ranges.txt','[a-z]#','im',1,1,2,1,4,0,0)
    RxRunTestCase('15_class_ranges.txt','[0-9]#','im',1,1,5,1,7,0,0)
    RxRunTestCase('15_class_ranges.txt','[~0-9]#','im',1,1,1,1,5,0,0)
    RxRunTestCase('16_case_classes.txt','[A-Z]#','im',1,2,1,2,4,0,0)
    RxRunTestCase('16_case_classes.txt','ABC','im',1,1,1,1,4,0,0)
    RxRunTestCase('17_class_punctuation.txt','[-x]','im',1,1,1,1,2,0,0)
    RxRunTestCase('17_class_punctuation.txt','[x-]','im',1,1,1,1,2,0,0)
    RxRunTestCase('17_class_punctuation.txt','[x~]','im',1,1,2,1,3,0,0)
    RxRunTestCase('18_numeric_escapes.txt','\x40#','im',1,1,1,1,4,0,0)
    RxRunTestCase('18_numeric_escapes.txt','\d064#','im',1,1,1,1,4,0,0)
    RxRunTestCase('18_numeric_escapes.txt','\o100#','im',1,1,1,1,4,0,0)
    RxRunTestCase('19_tab_escapes.txt','\tA','im',1,1,1,1,3,0,0)
    RxRunTestCase('19_tab_escapes.txt','\x09A','im',1,1,1,1,3,0,0)
    RxRunTestCase('19_tab_escapes.txt','\d009A','im',1,1,1,1,3,0,0)
    RxRunTestCase('20_optional.txt','colou?r','im',1,1,1,1,6,0,0)
    RxRunTestCase('20_optional.txt','colou#r','im',1,2,1,2,7,0,0)
    RxRunTestCase('21_closure_variants.txt','ab+','im',1,1,1,1,3,0,0)
    RxRunTestCase('21_closure_variants.txt','ab#','im',1,1,1,1,5,0,0)
    RxRunTestCase('21_closure_variants.txt','ab*','im',1,1,1,1,2,0,0)
    RxRunTestCase('21_closure_variants.txt','ab@','im',1,1,1,1,5,0,0)
    RxRunTestCase('22_nested_groups.txt','{{ab}c}#','im',1,1,1,1,7,0,0)
    RxRunTestCase('22_nested_groups.txt','{abc}#','im',1,1,1,1,7,0,0)
    RxRunTestCase('23_multiple_cursor.txt','Hello \cWor\cld!','im',1,1,1,1,13,1,10)
    RxRunTestCase('23_multiple_cursor.txt','Hello \cWorld!','im',1,1,1,1,13,1,7)
    RxRunTestCase('24_line_anchors.txt','^abc$','im',1,1,1,1,4,0,0)
    RxRunTestCase('24_line_anchors.txt','^xyz$','im',1,2,1,2,4,0,0)
    RxRunTestCase('24_line_anchors.txt','^bc','im',0,0,0,0,0,0,0)
    RxRunTestCase('25_dot_newline.txt','a.b','im',0,0,0,0,0,0,0)
    RxRunTestCase('25_dot_newline.txt','a\nb','im',1,1,1,2,2,0,0)
    RxRunTestCase('26_escaped_metacharacters.txt','a\+b','im',1,1,1,1,4,0,0)
    RxRunTestCase('26_escaped_metacharacters.txt','\?','im',1,1,4,1,5,0,0)
    RxRunTestCase('26_escaped_metacharacters.txt','\{','im',1,1,8,1,9,0,0)
    RxRunTestCase('27_alternative_order.txt','{whatever}|{what}','im',1,1,1,1,9,0,0)
    RxRunTestCase('27_alternative_order.txt','{what}|{whatever}','im',1,1,1,1,5,0,0)
    RxRunTestCase('28_complement_space.txt','[~ ]#','im',1,1,2,1,3,0,0)
    RxRunTestCase('30_prefix_case.txt','Ampersand','im',1,2,1,2,10,0,0)
    RxTestReport('')
    RxTestReport('--- MALFORMED PATTERN REJECTION ---')
    RxRunRejectTest('29_invalid_patterns.txt','\x4','im')
    RxRunRejectTest('29_invalid_patterns.txt','\d25','im')
    RxRunRejectTest('29_invalid_patterns.txt','\o400','im')
    RxRunRejectTest('29_invalid_patterns.txt','[abc','im')
    RxRunRejectTest('29_invalid_patterns.txt','{abc','im')
    RxTestReport('')
    RxRunLocalBoundaryTests()
    RxTestReport('TOTAL=' + Str(gTestTotalGI) + ' PASS=' + Str(gTestPassedGI) + ' FAIL=' + Str(gTestFailedGI))
    GotoBufferId(originalBufferI)
    gLogEnabledGI = previousLogEnabledI
    Warn('REGEXENGINE tests: ',Str(gTestPassedGI),' passed, ',Str(gTestFailedGI),' failed. See regexengine_test_report.txt')
end
