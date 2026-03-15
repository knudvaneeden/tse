// euler022.s  -  Project Euler Problem 22: Names Scores
// https://projecteuler.net/problem=22
//
// Using p022_names.txt (a 46 KB file with 5163 first names),
// sort names alphabetically, compute each name's letter-value
// (A=1 .. Z=26), multiply by its 1-based position in the sorted
// list, and sum all name scores.
//
// Answer: 871198282
//
// ASSUMPTIONS
//   The names file must be at c:\temp\p022_names.txt
//   Download from:
//     https://projecteuler.net/project/resources/p022_names.txt
//   Format: "MARY","PATRICIA","LINDA",..."NICHOLAS"
//   (one long line, names in double-quotes, comma-separated)
//
// SAL NOTES
//   - No arrays in SAL: names stored one-per-line in a scratch buffer
//   - Sort() operates on a marked block in the current buffer
//   - All variable declarations must be at the top of each proc
//   - Integer is 32-bit signed; answer 871198282 fits fine
//   - Asc() requires a string variable, not a literal -- use offset 64
//
// Version 1.0.0.0.4

string NAMES_FILE[255] = "c:\temp\p022_names.txt"

// ---------------------------------------------------------------------------
// NameScore()
//   Returns the letter-value sum (A=1..Z=26) of the name on the current line.
//   Uses ASCII offset: A=65, so ch - 64 gives A=1 .. Z=26.
//   Asc() needs a string variable, not a literal, so we use SubStr result.
// ---------------------------------------------------------------------------
integer proc NameScore()
    integer score
    integer i
    integer ch
    string  name[80]
    string  letter[1]

    score = 0
    name  = GetText(1, CurrLineLen())
    i     = 1
    while i <= Length(name)
        letter = SubStr(name, i, 1)
        ch     = Asc(letter)
        score  = score + (ch - 64)
        i      = i + 1
    endwhile
    return (score)
end

// ---------------------------------------------------------------------------
// ParseNamesIntoBuffer()
//   Reads all lines of srcId (raw file content), extracts every
//   double-quoted token, and appends one name per line into destId.
// ---------------------------------------------------------------------------
proc ParseNamesIntoBuffer(integer srcId, integer destId)
    integer i
    integer isFirst
    string  rawLine[255]
    string  token[80]
    string  ch[1]

    isFirst = TRUE
    GotoBufferId(srcId)
    BegFile()

    repeat
        rawLine = GetText(1, 255)
        i       = 1
        while i <= Length(rawLine)
            ch = SubStr(rawLine, i, 1)
            if ch == Chr(34)                // opening double-quote
                token = ""
                i     = i + 1
                while i <= Length(rawLine)
                    ch = SubStr(rawLine, i, 1)
                    if ch == Chr(34)        // closing double-quote
                        break
                    endif
                    token = token + ch
                    i     = i + 1
                endwhile
                if Length(token) > 0
                    GotoBufferId(destId)
                    if isFirst
                        // overwrite the single blank line in a new buffer
                        BegFile()
                        BegLine()
                        InsertText(token, _INSERT_)
                        isFirst = FALSE
                    else
                        EndFile()
                        AddLine(token)
                    endif
                    GotoBufferId(srcId)
                endif
            endif
            i = i + 1
        endwhile
    until not Down()
end

// ---------------------------------------------------------------------------
// main()
// ---------------------------------------------------------------------------
proc main()
    integer rawId
    integer parsedId
    integer totalScore
    integer namePos
    integer lineCount
    string  result[40]

    // -----------------------------------------------------------------------
    // Step 1: Check for the names file
    // -----------------------------------------------------------------------
    if not FileExists(NAMES_FILE)
        Warn("euler022: file not found: ", NAMES_FILE)
        Warn("Download from: projecteuler.net/project/resources/p022_names.txt")
        return()
    endif

    // -----------------------------------------------------------------------
    // Step 2: Load raw file into a scratch buffer
    // -----------------------------------------------------------------------
    rawId = CreateTempBuffer()
    if rawId == 0
        Warn("euler022: CreateTempBuffer failed (raw)")
        return()
    endif

    GotoBufferId(rawId)
    if not InsertFile(NAMES_FILE, _DONT_PROMPT_)
        Warn("euler022: InsertFile failed for ", NAMES_FILE)
        AbandonFile(rawId)
        return()
    endif

    // -----------------------------------------------------------------------
    // Step 3: Parse quoted names into a second scratch buffer (one per line)
    // -----------------------------------------------------------------------
    parsedId = CreateTempBuffer()
    if parsedId == 0
        Warn("euler022: CreateTempBuffer failed (parsed)")
        AbandonFile(rawId)
        return()
    endif

    ParseNamesIntoBuffer(rawId, parsedId)
    AbandonFile(rawId)

    // -----------------------------------------------------------------------
    // Step 4: Sort names alphabetically, case-insensitive
    // -----------------------------------------------------------------------
    GotoBufferId(parsedId)
    BegFile()
    lineCount = NumLines()
    MarkLine(1, lineCount)
    Sort(_IGNORE_CASE_)
    UnMarkBlock()

    // -----------------------------------------------------------------------
    // Step 5: Walk sorted list, accumulate total score
    // -----------------------------------------------------------------------
    totalScore = 0
    namePos    = 1
    BegFile()

    repeat
        totalScore = totalScore + NameScore() * namePos
        namePos    = namePos + 1
    until not Down()

    AbandonFile(parsedId)

    // -----------------------------------------------------------------------
    // Step 6: Report
    // -----------------------------------------------------------------------
    result = "Euler 22 answer: " + Str(totalScore)
    CopyToWinClip(result)
    Warn(result, "  (copied to clipboard)")
end
