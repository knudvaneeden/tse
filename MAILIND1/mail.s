/*
   MAILIND1 - plain-text email indexer for TSE

   Version : 1.0.0.0.2
   Date    : 2026-09-20
   LLM     : OpenAI Codex

   This version replaces the unsafe 1993 global-search loop.  It indexes
   RFC-style plain-text email headers inside the marked block only.
*/

string GSFrom[255]
string GSTo[255]
string GSDate[255]
string GSSubject[255]
string GSMessageId[255]

string proc FNTrim(string sourceS)
   integer doneI
   string resultS[255]
   resultS = sourceS
   doneI = FALSE
   while Length(resultS) > 0 and not doneI
      if resultS[1] == ' ' or resultS[1] == Chr(9)
         resultS = SubStr(resultS, 2, Length(resultS) - 1)
      else
         doneI = TRUE
      endif
   endwhile
   doneI = FALSE
   while Length(resultS) > 0 and not doneI
      if resultS[Length(resultS)] == ' ' or resultS[Length(resultS)] == Chr(9)
         resultS = SubStr(resultS, 1, Length(resultS) - 1)
      else
         doneI = TRUE
      endif
   endwhile
   return(resultS)
end

string proc FNHeaderValue(string lineS, integer prefixLengthI)
   string resultS[255]
   resultS = ""
   if Length(lineS) > prefixLengthI
      resultS = FNTrim(SubStr(lineS, prefixLengthI + 1, Length(lineS) - prefixLengthI))
   endif
   return(resultS)
end

string proc FNFit(string sourceS, integer widthI)
   string resultS[255]
   resultS = FNTrim(sourceS)
   if Length(resultS) > widthI
      resultS = SubStr(resultS, 1, widthI)
   endif
   while Length(resultS) < widthI
      resultS = resultS + " "
   endwhile
   return(resultS)
end

integer proc FNStartsWith(string lineS, string prefixS)
   integer resultI
   resultI = FALSE
   if Length(lineS) >= Length(prefixS)
      resultI = Lower(SubStr(lineS, 1, Length(prefixS))) == Lower(prefixS)
   endif
   return(resultI)
end

integer proc FNMarkLine(string markS)
   integer lineI
   PushLocation()
   GotoMark(markS)
   lineI = CurrLine()
   PopLocation()
   return(lineI)
end

proc PROCClearHeader()
   GSFrom = ""
   GSTo = ""
   GSDate = ""
   GSSubject = ""
   GSMessageId = ""
end

integer proc PROCReadHeader()
   integer linesReadI
   integer fieldsFoundI
   integer validI
   string lineS[255]
   PROCClearHeader()
   lineS = GetText(1, 255)
   GSFrom = FNHeaderValue(lineS, 5)
   fieldsFoundI = 0
   if GSFrom <> ""
      fieldsFoundI = fieldsFoundI + 1
   endif
   linesReadI = 0
   while linesReadI < 100 and CurrLine() < FNMarkLine("E")
      if Down()
         linesReadI = linesReadI + 1
         lineS = GetText(1, 255)
         if FNTrim(lineS) == ""
            linesReadI = 100
         else
            if FNStartsWith(lineS, "To:") and GSTo == ""
               GSTo = FNHeaderValue(lineS, 3)
               fieldsFoundI = fieldsFoundI + 1
            elseif FNStartsWith(lineS, "Date:") and GSDate == ""
               GSDate = FNHeaderValue(lineS, 5)
               fieldsFoundI = fieldsFoundI + 1
            elseif FNStartsWith(lineS, "Subject:") and GSSubject == ""
               GSSubject = FNHeaderValue(lineS, 8)
               fieldsFoundI = fieldsFoundI + 1
            elseif FNStartsWith(lineS, "Message-ID:") and GSMessageId == ""
               GSMessageId = FNHeaderValue(lineS, 11)
               fieldsFoundI = fieldsFoundI + 1
            endif
         endif
      else
         linesReadI = 100
      endif
   endwhile
   validI = fieldsFoundI >= 2 and (GSDate <> "" or GSSubject <> "" or GSMessageId <> "")
   return(validI)
end

proc PROCRemoveOldIndex()
   integer doneI
   integer safetyI
   integer indexAtBlockI
   string lineS[255]
   indexAtBlockI = FALSE
   GotoMark("S")
   if GetText(1, 255) == "MAILIND1 INDEX BEGIN"
      indexAtBlockI = TRUE
      if lFind("MAILIND1 INDEX END", "")
         GotoMark("S")
         doneI = FALSE
         safetyI = 0
         while not doneI and safetyI < 100000
            lineS = GetText(1, 255)
            if lineS == "MAILIND1 INDEX END"
               doneI = TRUE
            endif
            KillLine()
            safetyI = safetyI + 1
         endwhile
         if GetText(1, 255) == ""
            KillLine()
         endif
         BegLine()
         PlaceMark("S")
      endif
   endif
   if not indexAtBlockI
      GotoMark("S")
      if Up()
         if GetText(1, 255) == ""
            Up()
         endif
         if GetText(1, 255) == "MAILIND1 INDEX END"
            if lFind("MAILIND1 INDEX BEGIN", "B")
               BegLine()
               PlaceMark("I")
               GotoMark("I")
               doneI = FALSE
               safetyI = 0
               while not doneI and safetyI < 100000
                  if CurrLine() >= FNMarkLine("S")
                     doneI = TRUE
                  else
                     KillLine()
                  endif
                  safetyI = safetyI + 1
               endwhile
            endif
         endif
      endif
   endif
end

proc PROCInsertIndexFrame()
   GotoMark("S")
   BegLine()
   InsertLine("MAILIND1 INDEX BEGIN")
   AddLine("No.    Date                     From                     Subject")
   AddLine("------ ------------------------ ------------------------ --------------------------------")
   AddLine("MAILIND1 INDEX END")
   AddLine("")
   Down()
   BegLine()
   PlaceMark("S")
end

proc PROCInsertEntry(integer messageNumberI)
   string entryS[255]
   string numberS[16]
   numberS = Str(messageNumberI)
   entryS = "#" + FNFit(numberS, 5) + " " + FNFit(GSDate, 24) + " " + FNFit(GSFrom, 24) + " " + FNFit(GSSubject, 32)
   GotoMark("S")
   if lFind("MAILIND1 INDEX END", "b")
      BegLine()
      InsertLine(entryS)
   endif
end

proc PROCRememberBlock()
   GotoBlockBegin()
   BegLine()
   PlaceMark("S")
   GotoBlockEnd()
   EndLine()
   PlaceMark("E")
end

public proc mFindMsg()
   integer targetI
   integer foundI
   integer candidateLineI
   integer doneI
   integer targetFoundI
   string lineS[255]
   targetI = 0
   lineS = GetText(1, 255)
   if Length(lineS) >= 6
      if lineS[1] == '#'
         targetI = Val(FNTrim(SubStr(lineS, 2, 5)))
      endif
   endif
   if targetI > 0 and IsBlockInCurrFile()
      PROCRememberBlock()
      GotoMark("S")
      foundI = 0
      doneI = FALSE
      targetFoundI = FALSE
      while not doneI
         if lFind("^From:", "ix")
            if CurrLine() > FNMarkLine("E")
               doneI = TRUE
            else
               candidateLineI = CurrLine()
               if PROCReadHeader()
                  foundI = foundI + 1
                  if foundI == targetI
                     GotoLine(candidateLineI)
                     targetFoundI = TRUE
                     doneI = TRUE
                  endif
               else
                  GotoLine(candidateLineI + 1)
               endif
            endif
         else
            doneI = TRUE
         endif
      endwhile
      if targetFoundI
         BegLine()
      endif
   endif
end

public proc Mail()
   integer saveInsertI
   integer saveWordWrapI
   integer messageCountI
   integer headerLineI
   integer doneI
   saveInsertI = Set(Insert, ON)
   saveWordWrapI = Set(WordWrap, OFF)
   messageCountI = 0
   PROCRememberBlock()
   PROCRemoveOldIndex()
   PROCInsertIndexFrame()
   GotoMark("S")
   doneI = FALSE
   while not doneI
      if lFind("^From:", "ix")
         if CurrLine() > FNMarkLine("E")
            doneI = TRUE
         else
            headerLineI = CurrLine()
            if PROCReadHeader()
               messageCountI = messageCountI + 1
               PlaceMark("R")
               PROCInsertEntry(messageCountI)
               GotoMark("R")
            else
               GotoLine(headerLineI + 1)
            endif
         endif
      else
         doneI = TRUE
      endif
   endwhile
   Set(Insert, saveInsertI)
   Set(WordWrap, saveWordWrapI)
   GotoMark("S")
   Warn("MAILIND1 1.0.0.0.2 - OpenAI Codex: indexed ", messageCountI, " email message(s) from the marked block. Use Alt-H on an index entry to jump to its From: header.")
end

<Alt J> Main()
<Alt H> mFindMsg()

proc Main()
   if IsBlockInCurrFile()
      Mail()
   else
      Warn("MAILIND1 1.0.0.0.2 - OpenAI Codex: mark an email block in the current file before running the macro.")
   endif
end
