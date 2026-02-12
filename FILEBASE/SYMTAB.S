/* Sorted Symbol Tables
 *
 * Feb 2000 Loewe Opta GmbH, Helmut.Geisser@loewe.de
 *
 * This is no stand-alone macro, but is intended to be included in any
 * macro which may need a symbol table for mapping strings to strings.
 *
 * Symbol tables are buffers or files with structure
 *  symbol FS string FS
 *  symbol FS string FS
 * ..
 * with FS = arbitrary field separator
 *
 * Symbols are not sorted, newly entered symbols are first in list.
 * The field and subfield separators ù (Alt-249), ú (Alt-250)
 * and the CR/LF characters must not occur within [symbol] or [string].
 *
 * You may choose different field and subfield separators simply
 * by assigning other values to FS[] and SUBSEP[] before using any
 * symbol table function.
 *
 * Caution: Entries in the symbol table are limited to 250 bytes
 *          due to the size limit of SAL string variables
 *
 * Basic Functions:
 *
 * Create/delete symbol table:
 *  integer proc SymTabCreate()
 *  proc SymTabDelete(var integer SymTab)
 *
 * Read/write symbol table file:
 *  integer proc SymTabRead(integer SymTab, string filename)
 *  integer proc SymTabWrite(integer SymTab, string filename)
 *
 * Set/get/delete symbol:
 *  string proc SymSet(integer SymTab, string symbol, string symval)
 *  string proc SymGet(integer SymTab, string symbol)
 *  proc SymDel(integer SymTab, string symbol)
 *
 * Advanced functions:
 *
 * Count number of entries with same symbol name:
 *  integer proc SymCount(integer SymTab, string symbol)
 *
 * Find symbol or search table for a specific pattern:
 *  integer proc SymFind(integer SymTab, string symbol)
 *  integer proc SymNext(integer SymTab, string symbol)
 *  integer proc SymSearch(integer SymTab, string pattern, string options)
 *
 * Remove symbols with a specific pattern:
 *  proc SymRemove(integer SymTab, string pattern, string options)
 *
 * Get information on current symbol:
 *  string proc SymName(integer SymTab)
 *  string proc SymThis(integer SymTab)
 *  string proc SymElem(integer SymTab, integer element)
 *
 * Remove current symbol:
 *  proc SymPurge(integer SymTab)
 *
 * Copy/move symbols from one table to another:
 *  proc SymTabMerge(integer DestTab, integer SrcTab)
 *  proc SymCopy(integer DestTab, integer SrcTab, string pattern, string options)
 *  proc SymMove(integer DestTab, integer SrcTab, string pattern, string options)
 *
*/
string FS[] = "ù"       // field separator
string SUBSEP[] = "ú"   // subfield separator

/******************************************************************************
 * Get element of this symbol from table
 *-----------------------------------------------------------------------------
 * Returns: symbol name
 *-----------------------------------------------------------------------------
*/
string proc SymElem(integer SymTab, integer element)
    integer id
    string line[255], symval[255] = ""

    id = GetBufferId()
    if GotoBufferId(SymTab)
        line = GetText(1, CurrLineLen())
        symval = GetToken(line, FS, element)
    endif
    GotoBufferId(id)
    return(symval)
end

/******************************************************************************
 * Get this symbol name from table
 *-----------------------------------------------------------------------------
 * Returns: symbol name
 *-----------------------------------------------------------------------------
*/
string proc SymName(integer SymTab)
    return(SymElem(SymTab, 1))
end

/******************************************************************************
 * Get this symbol value from table
 *-----------------------------------------------------------------------------
 * Returns: symbol value
 *-----------------------------------------------------------------------------
*/
string proc SymThis(integer SymTab)
    return(SymElem(SymTab, 2))
end

/******************************************************************************
 * Purge this symbol from table
 *-----------------------------------------------------------------------------
*/
proc SymPurge(integer SymTab)
    integer id

    id = GetBufferId()
    if GotoBufferId(SymTab)
        KillLine() BegLine()
    endif
    GotoBufferId(id)
end

/******************************************************************************
 * Search for pattern in symbol table, starting from current line
 *-----------------------------------------------------------------------------
 * Returns: line number or 0 if not found
 *          if not found, line is reset to 1
 *-----------------------------------------------------------------------------
*/
integer proc SymSearch(integer SymTab, string pattern, string options)
    integer id, sym_index = 0

    id = GetBufferId()
    if GotoBufferId(SymTab)
        if lFind(pattern, options)
            sym_index = CurrLine()
        else
            BegFile()
        endif
    endif
    GotoBufferId(id)
    return(sym_index)
end

/******************************************************************************
 * Remove symbols from table
 *-----------------------------------------------------------------------------
*/
proc SymRemove(integer SymTab, string pattern, string options)
    integer id, sym_index

    id = GetBufferId()

    sym_index = SymSearch(SymTab, pattern, options + "g")
    while sym_index
        SymPurge(SymTab)
        sym_index = SymSearch(SymTab, pattern, options)
    endwhile

    GotoBufferId(id)
end

/******************************************************************************
 * Count symbols in table
 *-----------------------------------------------------------------------------
 * Returns: number of symbol entries found
 *-----------------------------------------------------------------------------
*/
integer proc SymCount(integer SymTab, string symbol)
    integer id, symbols = 0

    id = GetBufferId()
    if GotoBufferId(SymTab)
        if lFind(symbol + FS, "^g")
            repeat
                symbols = symbols + 1
            until not lRepeatFind()
        endif
    endif
    GotoBufferId(id)
    return(symbols)
end

/******************************************************************************
 * Find next symbol in table
 *-----------------------------------------------------------------------------
 * Returns: line number or 0 if not found
 *-----------------------------------------------------------------------------
*/
integer proc SymNext(integer SymTab, string symbol)
    integer id, sym_index = 0

    id = GetBufferId()
    if GotoBufferId(SymTab)
        if lFind(symbol + FS, "^+")
            sym_index = CurrLine()
        else
            BegFile()
        endif
    endif
    GotoBufferId(id)
    return(sym_index)
end

/******************************************************************************
 * Find symbol in table
 *-----------------------------------------------------------------------------
 * Returns: line number or 0 if not found
 *-----------------------------------------------------------------------------
*/
integer proc SymFind(integer SymTab, string symbol)
    integer id, sym_index = 0

    id = GetBufferId()
    if GotoBufferId(SymTab)
        if lFind(symbol + FS, "^g")
            sym_index = CurrLine()
        else
            BegFile()
        endif
    endif
    GotoBufferId(id)
    return(sym_index)
end

/******************************************************************************
 * Get symbol from table
 *-----------------------------------------------------------------------------
 * Returns: symbol value
 *-----------------------------------------------------------------------------
*/
string proc SymGet(integer SymTab, string symbol)
    integer sym_index

    sym_index = SymFind(SymTab, symbol)
    if sym_index
        return (SymThis(SymTab))
    endif
    return("")
end

/******************************************************************************
 * Write new symbol value or enter new symbol
 *-----------------------------------------------------------------------------
 * Returns: old symbol value
 *-----------------------------------------------------------------------------
*/
string proc SymSet(integer SymTab, string symbol, string symval)
    integer id, sym_index
    string prv_symval[255] = ""

    id = GetBufferId()
    if GotoBufferId(SymTab)
        sym_index = SymFind(SymTab, symbol)
        if sym_index
            prv_symval = SymThis(SymTab)
            KillLine() BegLine()
        endif
        InsertLine() BegLine() InsertText(symbol + FS + symval + FS)
    endif
    GotoBufferId(id)
    return(prv_symval)
end

/******************************************************************************
 * Delete symbol from table
 *-----------------------------------------------------------------------------
*/
proc SymDel(integer SymTab, string symbol)
    integer id, sym_index

    sym_index = SymFind(SymTab, symbol)
    if sym_index
        id = GetBufferId()
        if GotoBufferId(SymTab)
            KillLine() BegLine()
        endif
        GotoBufferId(id)
    endif
end

/******************************************************************************
 * Copy symbol table entries from one symbol table to another
 *-----------------------------------------------------------------------------
*/
proc SymCopy(integer DestTab, integer SrcTab, string pattern, string options)
    integer id, sym_index

    id = GetBufferId()

    sym_index = SymSearch(SrcTab, pattern, options + "g")
    while sym_index
        SymSet(DestTab, SymName(SrcTab), SymThis(SrcTab))
        sym_index = SymSearch(SrcTab, pattern, options + "+")
    endwhile

    GotoBufferId(id)
end

/******************************************************************************
 * Move symbol table entries from one symbol table to another
 *-----------------------------------------------------------------------------
*/
proc SymMove(integer DestTab, integer SrcTab, string pattern, string options)
    integer id, sym_index

    id = GetBufferId()

    sym_index = SymSearch(SrcTab, pattern, options + "g")
    while sym_index
        SymSet(DestTab, SymName(SrcTab), SymThis(SrcTab))
        GotoBufferId(SrcTab) KillLine() BegLine()
        sym_index = SymSearch(SrcTab, pattern, options)
    endwhile

    GotoBufferId(id)
end

/******************************************************************************
 * Merge symbol tables
 *-----------------------------------------------------------------------------
*/
proc SymTabMerge(integer DestTab, integer SrcTab)
    integer id

    id = GetBufferId()

    if GotoBufferId(SrcTab)
        BegFile()
        repeat
            SymSet(DestTab, SymName(SrcTab), SymThis(SrcTab))
        until not Down()
    endif

    GotoBufferId(id)
end

/******************************************************************************
 * Read symbol table from file
 *-----------------------------------------------------------------------------
 * Returns: symbol table read
 *-----------------------------------------------------------------------------
*/
integer proc SymTabRead(integer SymTab, string filename)
    integer id, symtab_read = 0

    id = GetBufferId()
    if GotoBufferId(SymTab)
        BegFile()
        PushBlock()
        symtab_read = InsertFile(filename, _DONT_PROMPT_)
        UnMarkBlock()
        PopBlock()
    endif
    GotoBufferId(id)
    return(symtab_read)
end

/******************************************************************************
 * Write symbol table to file
 *-----------------------------------------------------------------------------
 * Returns: symbol table saved
 *-----------------------------------------------------------------------------
*/
integer proc SymTabWrite(integer SymTab, string filename)
    integer id, symtab_saved = 0

    id = GetBufferId()
    if GotoBufferId(SymTab)
        symtab_saved = SaveAs(filename, _OVERWRITE_|_DONT_PROMPT_)
    endif
    GotoBufferId(id)
    return(symtab_saved)
end

/******************************************************************************
 * Create symbol table
 * Returns: symbol table identifier (non-zero), or 0 on failure
 *-----------------------------------------------------------------------------
*/
integer proc SymTabCreate()
    integer id = GetBufferId()
    CreateTempBuffer()
    return (GotoBufferId(id))
end

/******************************************************************************
 * Delete symbol table
 *-----------------------------------------------------------------------------
*/
proc SymTabDelete(var integer SymTab)
    integer state

    state = SetHookState(_OFF_, _ON_FILE_QUIT_)
    AbandonFile(SymTab)
    SetHookState(state, _ON_FILE_QUIT_)
    SymTab = 0
end

