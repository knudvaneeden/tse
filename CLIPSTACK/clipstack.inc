/*
   File       : clipstack.inc
   Purpose    : Standalone clipboard stack library for TSE SAL.
   Version    : 1.0.0.0.7
   Date       : 2026-09-02
   LLM        : OpenAI Codex

   No other include files are required by this library.

   Public actions:

      PROCPushClipboard()
      PROCPopClipboard()
      PROCPushClipboardWin()
      PROCPopClipboardWin()

   Example:

      PROCPushClipboard()
      // Code that changes the TSE clipboard.
      PROCPopClipboard()
*/

#ifdef CLIPSTACK_INCLUDED
#else
   #define CLIPSTACK_INCLUDED TRUE

   integer clipStackTopI = 0
   integer clipStackWinTopI = 0
   string clipStackPrefixS[40] = "_codex_clipstack_"

   string proc FNClipStackDataName(integer levelI)
      return(clipStackPrefixS + "data_" + Str(levelI))
   end

   string proc FNClipStackInfoName(integer levelI)
      return(clipStackPrefixS + "info_" + Str(levelI))
   end

   string proc FNClipStackWinDataName(integer levelI)
      return(clipStackPrefixS + "win_data_" + Str(levelI))
   end

   integer proc FNClipStackOpen(string bufferNameS)
      integer bufferIdI = 0

      bufferIdI = GetBufferId(bufferNameS)
      if (bufferIdI == 0)
         bufferIdI = CreateBuffer(bufferNameS, _SYSTEM_)
      endif

      if (bufferIdI <> 0)
         if GotoBufferId(bufferIdI)
         or (GetBufferId() == bufferIdI)
            return(bufferIdI)
         endif
      endif

      return(0)
   end

   integer proc PROCPushClipboard()
      integer originalBufferIdI = GetBufferId()
      integer oldUnmarkAfterPasteI = 0
      integer dataBufferIdI = 0
      integer infoBufferIdI = 0
      integer blockTypeI = 0
      integer columnWidthI = 0
      integer resultI = FALSE

      PushBlock()
      oldUnmarkAfterPasteI = Set(UnMarkAfterPaste, OFF)
      clipStackTopI = clipStackTopI + 1

      dataBufferIdI = FNClipStackOpen(FNClipStackDataName(clipStackTopI))
      if (dataBufferIdI <> 0)
         UnMarkBlock()
         EmptyBuffer()

         if Paste()
         or ((NumLines() == 0) and (CurrLineLen() == 0))
            blockTypeI = IsBlockMarked()
            columnWidthI = CurrLineLen()

            infoBufferIdI = FNClipStackOpen(
               FNClipStackInfoName(clipStackTopI))
            if (infoBufferIdI <> 0)
               EmptyBuffer()
               AddLine(Str(blockTypeI) + " " + Str(columnWidthI))
               resultI = TRUE
            endif
         endif
      endif

      if (resultI == FALSE)
         clipStackTopI = clipStackTopI - 1
      endif

      Set(UnMarkAfterPaste, oldUnmarkAfterPasteI)
      GotoBufferId(originalBufferIdI)
      PopBlock()

      if (resultI == FALSE)
         Warn("PROCPushClipboard: unable to save the TSE clipboard")
      endif

      return(resultI)
   end

   integer proc PROCPopClipboard()
      integer originalBufferIdI = GetBufferId()
      integer dataBufferIdI = 0
      integer infoBufferIdI = 0
      integer blockTypeI = 0
      integer columnWidthI = 0
      integer resultI = FALSE
      string infoLineS[80] = ""

      if (clipStackTopI <= 0)
         Warn("PROCPopClipboard: the clipboard stack is empty")
         return(FALSE)
      endif

      PushBlock()

      infoBufferIdI = FNClipStackOpen(FNClipStackInfoName(clipStackTopI))
      if (infoBufferIdI <> 0)
         BegFile()
         infoLineS = GetText(1, CurrLineLen())
         blockTypeI = Val(GetToken(infoLineS, " ", 1))
         columnWidthI = Val(GetToken(infoLineS, " ", 2))

         dataBufferIdI = FNClipStackOpen(FNClipStackDataName(clipStackTopI))
         if (dataBufferIdI <> 0)
            UnMarkBlock()

            if (blockTypeI == 0)
               if GotoBufferId(Query(ClipBoardId))
               or (GetBufferId() == Query(ClipBoardId))
                  EmptyBuffer()
                  resultI = TRUE
               endif
            else
               case blockTypeI
                  when _LINE_
                     MarkLine(1, NumLines())
                  when _COLUMN_
                     MarkColumn(1, 1, NumLines(), columnWidthI)
                  when _INCLUSIVE_, _NONINCLUSIVE_
                     BegFile()
                     MarkChar()
                     EndFile()
                  otherwise
                     blockTypeI = 0
               endcase

               if (blockTypeI <> 0)
                  if Copy()
                     resultI = TRUE
                  endif
               endif
            endif

            if GotoBufferId(dataBufferIdI)
            or (GetBufferId() == dataBufferIdI)
               UnMarkBlock()
               EmptyBuffer()
            endif

            if GotoBufferId(infoBufferIdI)
            or (GetBufferId() == infoBufferIdI)
               EmptyBuffer()
            endif
         endif
      endif

      if (resultI)
         clipStackTopI = clipStackTopI - 1
      endif

      GotoBufferId(originalBufferIdI)
      PopBlock()

      if (resultI == FALSE)
         Warn("PROCPopClipboard: unable to restore the TSE clipboard")
      endif

      return(resultI)
   end

   integer proc PROCPushClipboardWin()
      integer originalBufferIdI = GetBufferId()
      integer oldUnmarkAfterPasteI = 0
      integer dataBufferIdI = 0
      integer resultI = FALSE

      PushBlock()
      oldUnmarkAfterPasteI = Set(UnMarkAfterPaste, OFF)
      clipStackWinTopI = clipStackWinTopI + 1

      dataBufferIdI = FNClipStackOpen(
         FNClipStackWinDataName(clipStackWinTopI))
      if (dataBufferIdI <> 0)
         UnMarkBlock()
         EmptyBuffer()

         if PasteFromWinClip()
         or ((NumLines() == 0) and (CurrLineLen() == 0))
            resultI = TRUE
         endif
      endif

      if (resultI == FALSE)
         clipStackWinTopI = clipStackWinTopI - 1
      endif

      Set(UnMarkAfterPaste, oldUnmarkAfterPasteI)
      GotoBufferId(originalBufferIdI)
      PopBlock()

      if (resultI == FALSE)
         Warn("PROCPushClipboardWin: unable to save the Windows clipboard")
      endif

      return(resultI)
   end

   integer proc PROCPopClipboardWin()
      integer originalBufferIdI = GetBufferId()
      integer dataBufferIdI = 0
      integer resultI = FALSE

      if (clipStackWinTopI <= 0)
         Warn("PROCPopClipboardWin: the Windows clipboard stack is empty")
         return(FALSE)
      endif

      PushBlock()

      dataBufferIdI = FNClipStackOpen(
         FNClipStackWinDataName(clipStackWinTopI))
      if (dataBufferIdI <> 0)
         UnMarkBlock()
         BegFile()
         MarkChar()
         EndFile()

         if CopyToWinClip()
            resultI = TRUE
         endif

         if (resultI)
            UnMarkBlock()
            EmptyBuffer()
            clipStackWinTopI = clipStackWinTopI - 1
         endif
      endif

      GotoBufferId(originalBufferIdI)
      PopBlock()

      if (resultI == FALSE)
         Warn("PROCPopClipboardWin: unable to restore the Windows clipboard")
      endif

      return(resultI)
   end

#endif
