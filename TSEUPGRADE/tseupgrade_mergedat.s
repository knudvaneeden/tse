// Version: 1.0.0.0.53
// Created: 2026-10-31 18:43:55
// Derived from supplied SemWare SAL sources; supporting wrappers added.
// Duplicate removal extracted from TSE 4.50.rc24 compile.s: isSetupSame/RemoveDuplicateSetups.
// The supplied menu compares 20 lines per compiler setup; that rule is retained.
INTEGER data_id
STRING EyeCatcher[] = "Semware compile macro data file"

INTEGER PROC LoadData(string filenameS)
 INTEGER id = CreateTempBuffer(), ok = FALSE
 IF id
  ok = InsertFile(filenameS, _DONT_PROMPT_)
  BegFile()
  IF NOT ok OR GetText(1, CurrLineLen()) <> EyeCatcher
   AbandonFile(id)
   RETURN(0)
  ENDIF
 ENDIF
 RETURN(id)
END

integer proc isSetupSame(integer id)
    string data[255], merge[255]

    do 20 times
        GotoBufferId(data_id)
        data  = GetText(1,SizeOf(data))
        Down()
        GotoBufferId(id)
        merge = GetText(1,SizeOf(merge))
        Down()
        if data <> merge
            return (FALSE)
        endif
    enddo
    return (TRUE)
end

proc RemoveDuplicateSetups(integer merge_id)
    integer data_line, merge_line

    GotoBufferId(data_id)
    BegFile()
    if lFind(Chr(30),"^")
        repeat
            data_line = CurrLine()
            Down()
            Message("Checking: ",GetText(1,132))
            Up()
            GotoBufferId(merge_id)
            BegFile()
            while lRepeatFind()
                merge_line = CurrLine()
                GotoBufferId(data_id)
                GotoLine(data_line)
                if isSetupSame(merge_id)
                    GotoLine(merge_line)
                    KillLine(20)
                    Up()
                endif
            endwhile
            GotoBufferId(data_id)
        until not lRepeatFind()
    endif
    GotoBufferId(merge_id)
end


INTEGER PROC MergeData(string currentS, string previousS)
 INTEGER originalId = GetBufferId(), mergeId = 0, saved = FALSE
 INTEGER originalEol = Query(EOLType), originalEntab = Query(EntabOnSave)
 STRING backupS[255] = currentS + ".before_merge.bak"
 IF Upper(currentS) == Upper(previousS)
  Warn("Current and previous DAT paths must differ.")
  RETURN(FALSE)
 ENDIF
 IF FileExists(backupS) OR GetBufferId(currentS) OR GetBufferId(previousS)
  Warn("Close DAT buffers; move any existing backup first: ", backupS)
  RETURN(FALSE)
 ENDIF
 PushPosition()
 PushBlock()
 data_id = LoadData(currentS)
 IF data_id
  mergeId = LoadData(previousS)
 ENDIF
 IF data_id AND mergeId
  RemoveDuplicateSetups(mergeId)
  BegFile()
  IF lFind(Chr(30), "^g")
   UnMarkBlock()
   MarkLine()
   EndFile()
   GotoBufferId(data_id)
   EndFile()
   AddLine()
   CopyBlock()
   Set(EOLType, 2)
   Set(EntabOnSave, OFF)
   // Back up the on-disk destination, not the already-merged buffer.
   GotoBufferId(mergeId)
   EmptyBuffer()
   IF InsertFile(currentS, _DONT_PROMPT_) AND SaveAs(backupS)
    GotoBufferId(data_id)
    saved = SaveAs(currentS, _OVERWRITE_)
   ENDIF
  ELSE
   saved = TRUE
  ENDIF
 ELSE
  Warn("Could not load valid compiler DAT files.")
 ENDIF
 Set(EOLType, originalEol)
 Set(EntabOnSave, originalEntab)
 IF mergeId
  AbandonFile(mergeId)
 ENDIF
 IF data_id
  AbandonFile(data_id)
 ENDIF
 PopBlock()
 PopPosition()
 GotoBufferId(originalId)
 RETURN(saved)
END

PROC Main()
 STRING iniFilenameS[255] = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_) + "tseupgrade.ini"
 STRING currentS[255] = GetProfileStr("tseupgrade", "new_compile_data", "", iniFilenameS)
 STRING previousS[255] = GetProfileStr("tseupgrade", "old_compile_data", "", iniFilenameS)
 WriteProfileStr("result", "saved", "false", iniFilenameS)
 IF currentS == "" OR previousS == ""
  Warn("Set new_compile_data and old_compile_data in ", iniFilenameS)
  RETURN()
 ENDIF
 IF MergeData(currentS, previousS)
  WriteProfileStr("result", "saved", "true", iniFilenameS)
  Message("Compiler data merge complete: ", currentS)
 ELSE
  Warn("Compiler data merge failed. Inspect inputs/backup: ", currentS)
 ENDIF
END
