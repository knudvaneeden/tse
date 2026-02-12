/* ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ÚÄÙ TSE Booklet Printer    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 ³ SOFTWARE:    TSEBOOK
 ³ VERSION:     1.10.00
 ³ DATE:        04/21/95 08:50 am
 ³ REV. DATE:   10/16/95 08:59 pm
 ³ AUTHOR:      Mike Chambers
 ³ TYPE:        External Macro
 ³ BASED ON:    PCBOOK (c) 1990 Ziff-Davis & Jay Munro
 ³ PATH:        C:\TSEPRO\USERMAC\TSEBOOK\TSEBOOK.S
 ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³ Revision History                                                         ³
 ³              0.10 Initial functionality                                  ³
 ³              0.11 Added 5 Booklet Font Style, Integration to TSE.UI      ³
 ³              0.12 Added simple Duplex printing, Integration to TSE.UI    ³
 ³              1.00 Released for TSE 2.5                                   ³
 ³              1.01 Fixed to accomodate TSE.UI integration & ExecMacro()   ³
 ³              1.02 Optimized PCL routines; cut macro size in half.        ³
 ³              1.10 Rewrote Duplexing routines; re-Release for TSEPro 2.5  ³
 ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
 ³                                                                          ³
 ³ FUNCTION:    Prints booklet style from TSE to PCL (LaserJet) Printers.   ³
 ³              Prints Duplex style from TSE to PCL (LaserJet) Printers.    ³
 ³                                                                          ³
 ³              TSEBOOK is a print enhancement macro which allows           ³
 ³              TSE to print four very readable pages each sheet            ³
 ³              of paper.  It does so by printing two 80x66 pages           ³
 ³              on each side using landscape orientation a                  ³
 ³              monospace font at 16.66 pitch.  The macro will              ³
 ³              prompt you halfway through printing to reload the           ³
 ³              printed pages in the intray so the second side can          ³
 ³              be printed.                                                 ³
 ³                                                                          ³
 ³              Although optimum results are obtained with a                ³
 ³              LaserJet, any PCL compatible printer which                  ³
 ³              supports a monospace font at 16.66 pitch and                ³
 ³              landscape mode should work.  TSEBOOK has been               ³
 ³              tested with a DeskJet 1200C.  Duplex Mode may not function  ³
 ³              properly on printers which do not support reverse           ³
 ³              landscape printing (Esc'&l3O').                             ³
 ³                                                                          ³
 ³              The idea for TSEBOOK was loosely based on a                 ³
 ³              PC-Magazine utility, PCBOOK, (c) 1990 by                    ³
 ³              Ziff-Davis publishing and Jay Munro. The TSEBOOK            ³
 ³              macro was written to take advantage of TSE's                ³
 ³              features and integrate booklet printing with TSE's          ³
 ³              existing Print interface and options.                       ³
 ³                                                                          ³
 ³ USAGE:       TSEBook can be added to your potpourri menu, executed       ³
 ³              manually, or added to the TSE print menu.  Refer to the     ³
 ³              TSEBOOK.DOC file for more details.                          ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

//#DEFINE TESTING  TRUE

         //  Font Type Selection

constant LinePrinter            = 0,
         Courier                = 1,
         CourierBold            = 2,
         Gothic                 = 3,
         GothicBold             = 4


         // Page Type Selection

constant Booklet                = 0,
         Duplex                 = 1


         // Defaults

integer  FontSelection          = Courier
integer  PageSelection          = Booklet



string   TseBookFileName[12]    = 'TSEBOOK.OUT' // Intermediate file
string   Esc[1]                 = chr(27)       // 'escape' code
string   FF[1]                  = Chr(12)       // Page Feed
integer  page                   = 0             // number of pages to print
string   SaveDevice[48]         = ''            // Original print dev setting
integer  ActualPages            = 0             // Number of pages in file
integer  BookletBuffer          = 0             // BufferId for print buffer
string   ReInsertMessage[60]    =
         'When printing stops, insert the pages in the input tray  '




/*--------------------------  TSE.UI Interface ---------------------------*/

proc SetFontSelection(integer f)                // Changes style from menu
        FontSelection = f
end

Menu FontMenu()
    title = 'TSEBook Font Style'                // Font Style menu
    history
    command = SetFontSelection(  MenuOption()-1)

    "&LinePrinter"      ,, CloseBefore
    "&Courier"          ,, CloseBefore
    "CourierBold"       ,, CloseBefore
    "&Gothic"           ,, CloseBefore
    "GothicBo&ld"       ,, CloseBefore
end

proc FontMenuProc()                             // Interface to TSE.UI
        FontMenu()
end



proc SetPageSelection(integer f)                // Changes style from menu
        PageSelection = f
end

Menu PageMenu()
    title = 'TSEBook Page Style'                // Page Style menu
    history
    command = SetPageSelection(  MenuOption()-1)

    "&Booklet "         ,, CloseBefore
    "&Duplex  "         ,, CloseBefore
end

proc PageMenuProc()                             // Interface to TSE.UI
        PageMenu()
end

/*--------------------------------------------------------------------------*/

proc AddString(string s)                        // Add a string to the
        integer cb = GetBufferId()              // Booklet image buffer
        GotoBufferId(BookletBuffer)
        endfile()
        InsertText(s)
        endfile()
        GotoBufferId(cb)
end

integer proc CountString(string s)              // Return number of instances
    integer i = 0                               // of 's' in buffer
    if lfind(s,'g')
       repeat
         i = i + 1
       until not lRepeatFind(_forward_)
    endif
    return(i)
end



integer proc GetPage(integer p)                 // Marks a character block
        integer i = 0                           // containing the specified
                                                // page
        if p > ActualPages                      // Return false for blank
                return(false)                   // pages
        endif

        UnMarkBlock()                           // Release previous block

        if lfind(ff,'g')                        // skip to 'Pth' formfeed
           repeat
              i = i + 1
           until (i == p) or
                 not lRepeatFind(_forward_)
        endif
                                                // Hmm, shouldn't get here
        if i <> p                               // but just in case...
                return(false)
        endif

        MarkChar()                              // Drop Anchor here
        if not lRepeatFind(_backward_)          // Cruise back to previous FF
                Begfile()                       // or beginning of file
        endif
        if CurrChar() == 12 Right() endif       // if not at BOF
        MarkChar()                              // Complete the block

        return(p)                               // return page number
end


proc AddPageBlock()                             // Add block to the
        integer cb = getbufferid()              // Booklet image buffer
        GotoBufferId(BookletBuffer)
        CopyBlock()
        GotoBufferId(cb)
end


#IFDEF TESTING

proc mPrintFile()
        integer sb = GotoBufferId(BookLetBuffer)
        List('BookLetBuffer',80)
        GotoBufferId(sb)
end

#ELSE

proc mPrintFile()
        PrintFile()
end

#ENDIF

/*--------------------------------------------------------------------------*/



/*---------------------- TSEBOOK Internal Print Settings -------------------*/
/* Note:  TSEBook saves every single one of your print option settings and
          restores them when done.  These settings are used only for TSEBOOK's
          intermediate files.  Don't change them.  If you want your print to
          look different, change your TSE print option settings from the
          print menu or in your cfg file.                                   */

proc SetBookFileSettings()                      // Set TSE print vars for print
        Set ( PrintAddFF ,        true )        // to intermediate file
        Set ( PrintCopies ,       1 )
        Set ( PrintDevice ,       TseBookFileName)
        Set ( PrintInit ,         '' )
        Set ( PrintLinesPerPage , 66 )
        Set ( PrintPause ,        false )
        Set ( PrintRightMargin ,  80 )
        Set ( PrintUseFF ,        true )
        Set ( PrintLeftMargin ,   0 )
end


proc SetBookPrintSettings()                     // Set TSE print Vars for print
        Set ( PrintAddFF ,        false )       // to actual print device
        Set ( PrintBotMargin ,    0 )
        Set ( PrintCopies ,       1 )
        Set ( PrintDevice ,       SaveDevice )
        Set ( PrintFooter ,       '' )
        Set ( PrintHeader ,       '' )
        Set ( PrintInit ,         '' )
        Set ( PrintLeftMargin ,   0 )
        Set ( PrintLineNumbers ,  false )
        Set ( PrintLineSpacing ,  1 )
        Set ( PrintLinesPerPage , 0 )
        Set ( PrintPause ,        false )
        Set ( PrintRightMargin ,  255 )
        Set ( PrintTopMargin ,    0 )
        Set ( PrintUseFF ,        false )
end

proc InitPrintJob()
   integer cb = GetBufferId()
   BookletBuffer = CreateBuffer('booklet')      // Create buf for booklet image
   GotoBufferId(cb)
   SetBookFileSettings()
   if isBlockMarked()                           // if block is marked
        PrintBlock()                            //    print block to file
   else                                         // otherwise, print the
        PrintFile()                             // entire buffer to file
   endif
   SetBookPrintSettings()                       // Reset TSE vars for printing
   EditFile(TseBookFileName)                    // Edit the print buffer
   ActualPages = CountString(ff)                // Calculate # pages in file
   page = ActualPages
   if page Mod 4                                // If page isn't multiple of
      page = page + (4 - page Mod 4)            // four, round up
   endif
end


proc SetCourier()
    AddString(format(Esc, "(10U"))              // PC-8 symbol set
    AddString(format(Esc, "(s0P"))              // Monospace characters
    AddString(format(Esc, "(s16.67H"))          // Condensed pitch
    Addstring(format(Esc, "(s0S"))              // Type Style Normal
    AddString(format(Esc, "(s0B"))              // Stroke Weight Normal
    AddString(format(Esc, "(s3T"))              // Typeface Courier
    AddString(format(Esc, "&l5.45C"))           // Vertical Motion Index
    AddString(format(Esc, "&l0L"))              // Disable auto feed at 66 lines
    AddString(format(Esc, "&s0C"))              // Enable Line Wrap
    AddString(format(Esc, "&l2E"))              // Top margin 2 lines
end

proc SetCourierBold()
    AddString(format(Esc, "(10U"))              // PC-8 symbol set
    AddString(format(Esc, "(s0P"))              // Monospace characters
    AddString(format(Esc, "(s16.67H"))          // Condensed pitch
    Addstring(format(Esc, "(s0S"))              // Type Style Normal
    AddString(format(Esc, "(s1B"))              // Stroke Weight Bold
    AddString(format(Esc, "(s3T"))              // Typeface Courier
    AddString(format(Esc, "&l5.45C"))           // Vertical Motion Index
    AddString(format(Esc, "&l0L"))              // Disable auto feed at 66 lines
    AddString(format(Esc, "&s0C"))              // Enable Line Wrap
    AddString(format(Esc, "&l2E"))              // Top margin 2 lines
end

Proc SetGothic()
    AddString(format(Esc, "(10U"))              // PC-8 symbol set
    AddString(format(Esc, "(s0P"))              // Monospace characters
    AddString(format(Esc, "(s16.67H"))          // Condensed pitch
    Addstring(format(Esc, "(s0S"))              // Type Style Normal
    AddString(format(Esc, "(s0B"))              // Stroke Weight Normal
    AddString(format(Esc, "(s6T"))              // Typeface Gothic
    AddString(format(Esc, "&l5.45C"))           // Vertical Motion Index
    AddString(format(Esc, "&l0L"))              // Disable auto feed at 66 lines
    AddString(format(Esc, "&s0C"))              // Enable Line Wrap
    AddString(format(Esc, "&l2E"))              // Top margin 2 lines
end

proc SetGothicBold()
    AddString(format(Esc, "(10U"))              // PC-8 symbol set
    AddString(format(Esc, "(s0P"))              // Monospace characters
    AddString(format(Esc, "(s16.67H"))          // Condensed pitch
    Addstring(format(Esc, "(s0S"))              // Type Style Normal
    AddString(format(Esc, "(s1B"))              // Stroke Weight Bold
    AddString(format(Esc, "(s6T"))              // Gothic Typeface
    AddString(format(Esc, "&l5.45C"))           // Vertical Motion Index
    AddString(format(Esc, "&l0L"))              // Disable auto feed at 66 lines
    AddString(format(Esc, "&s0C"))              // Enable Line Wrap
    AddString(format(Esc, "&l2E"))              // Top margin 2 lines
end

proc SetLinePrinter()
    AddString(format(Esc, "(10U"))              // PC-8 symbol set
    AddString(format(Esc, "(s0P"))              // Monospace characters
    AddString(format(Esc, "(s16.67H"))          // Condensed pitch
    Addstring(format(Esc, "(s0S"))              // Type Style Normal
    AddString(format(Esc, "(s0B"))              // Stroke Weight Normal
    AddString(format(Esc, "(s0T"))              // Line Printer Typeface
    AddString(format(Esc, "&l5.45C"))           // Vertical Motion Index
    AddString(format(Esc, "&l0L"))              // Disable auto feed at 66 lines
    AddString(format(Esc, "&s0C"))              // Enable Line Wrap
    AddString(format(Esc, "&l2E"))              // Top margin 2 lines
end


proc SetForLeftPage()
    AddString(format(Esc, "9"))                 // Reset left - right margins
    AddString(format(Esc, "&a0l80M"))           // set left margin 0, right 80
    AddString(format(Esc,"&a0r0C"))             // Move to top of logical page
end


proc SetForRightPage()
    AddString(format(Esc, "9"))                 // Reset left - right margins
    AddString(format(Esc, "&a95l175M"))         // set left margin 95, right 175
    AddString(format(Esc,"&a0r95C"))            // Move to top of logical page
end
/*--------------------------------------------------------------------------*/



/*------------------------- Booklet PCL Commands ---------------------------*/


proc BookletPrinterSetup()
     AddString(format(Esc, "E"))                // Reset PCL printer
     AddString(format(Esc, "&l1O"))             // Select landscape
     case FontSelection
       when Courier
             SetCourier()
       when CourierBold
             SetCourierBold()
       when Gothic
             SetGothic()
       when GothicBold
             SetGothicBold()
       Otherwise
             SetLinePrinter()
     endcase
End

/*------------------------ Booklet Style Routines ---------------------------*/

proc InitBooklet()
   InitPrintJob()
   BookletPrinterSetup()                        // Initialize the printer
end



proc PrintBooklet()
   integer p                                    // Page to print
   integer halfway
   integer cb  = GetBufferId()                  // current bufferid
   p = -1

   halfway = page / 2                           // calc front/back breakpoint
   Repeat                                       // Print right side (odd) first
     p = p + 2                                  // skip the even pages

     If GetPage(p)                              // If blank, then skip it
        SetForRightPage()                       // Set margins for right side
        AddPageBlock()                          // Print the right page
     endif

     If GetPage(1 + page - p)                   // Don't print blank pages
        SetForLeftPage()                        // Set margins for left side
        AddPageBlock()                          // Print the left side (even)
     endif

     AddString(FF)                              // Eject physical page

     if p + 2 == halfway + 1                    // When half finished
        GotoBufferId(BookletBuffer)             // print the buffer
        mPrintFile()
        EmptyBuffer()                           // Empty it for the backside
        BookletPrinterSetup()                   // Re-Init the printer in case
        GotoBufferId(cb)                        // the setup was cleared
        Warn(ReInsertMessage)                   // wait for user to reload
        message("Printing Side 2 ")             // pages, then proceed
     endif

   Until p + 2 > page

   GotoBufferId(BookletBuffer)
   AddString(Format(Esc,"E"))                   // Add a printer reset
   mPrintFile()                                 // Print the Buffer
   AbandonFile()
   GotoBufferId(cb)                             // Return to intermediate buf
   message("Booklet Printing Completed ")

end

/*--------------------------------------------------------------------------*/

/*------------------------- Duplex PCL Commands ----------------------------*/


proc DuplexPrinterSetup()
     case FontSelection
       when Courier
             SetCourier()
       when CourierBold
             SetCourierBold()
       when Gothic
             SetGothic()
       when GothicBold
             SetGothicBold()
       Otherwise
             SetLinePrinter()
     endcase
End

/*------------------------ Duplex Style Routines ---------------------------*/

proc InitDuplex()
   InitPrintJob()
   AddString(format(Esc, "E"))                  // Reset PCL printer
   AddString(format(Esc, "&l1O"))               // Select landscape
   DuplexPrinterSetup()                         // Initialize the printer
end



proc PrintDuplex()
   integer PageDelta
   integer p                                    // Page to print
   integer cb  = GetBufferId()                  // current bufferid

   PageDelta = 4
   p = -3

   Repeat
     p = p + PageDelta                          //

     If GetPage(p)                              // If blank, then skip it
        SetForLeftPage()                        // Set margins for left side
        AddPageBlock()                          // Print the left page (odd)
     endif

     If GetPage(p + 1)                          // Don't print blank pages
        SetForRightPage()                       // Set margins for right side
        AddPageBlock()                          // Print the right (even)
     endif

     AddString(FF)                              // Eject physical page

     if p + PageDelta > page
        GotoBufferId(BookletBuffer)             // print the buffer
        mPrintFile()
        EmptyBuffer()                           // Empty it for the backside
        AddString(format(Esc, "E"))             // Reset PCL printer
        AddString(format(Esc, "&l3O"))          // Select reverse landscape
        DuplexPrinterSetup()                    // Re-Init the printer in case
        GotoBufferId(cb)                        // the setup was cleared
        Warn(ReInsertMessage)                   // wait for user to reload
        message("Printing Side 2 ")             // pages, then proceed
        p = p + 6
        PageDelta = -4
     endif

   Until p + PageDelta == -1

   GotoBufferId(BookletBuffer)
   AddString(Format(Esc,"E"))                   // Add a printer reset
   mPrintFile()                                 // Print the Buffer
   AbandonFile()
   GotoBufferId(cb)                             // Return to intermediate buf
   message("Duplex Printing Completed ")
end


/*--------------------------------------------------------------------------*/



proc Main()
        integer SaveAddFF        = Query ( PrintAddFF )
        integer SaveBotMargin    = Query ( PrintBotMargin )
        integer SaveCopies       = Query ( PrintCopies )
        integer SaveFirstPage    = Query ( PrintFirstPage )
        string  SaveFooter[4]    = Query ( PrintFooter )
        string  SaveHeader[4]    = Query ( PrintHeader )
        string  SaveInit[60]     = Query ( PrintInit )
        integer SaveLastPage     = Query ( PrintLastPage )
        integer SaveLeftMargin   = Query ( PrintLeftMargin )
        integer SaveLineNumbers  = Query ( PrintLineNumbers )
        integer SaveLineSpacing  = Query ( PrintLineSpacing )
        integer SaveLinesPerPage = Query ( PrintLinesPerPage )
        integer SavePause        = Query ( PrintPause )
        integer SaveRightMargin  = Query ( PrintRightMargin )
        integer SaveTopMargin    = Query ( PrintTopMargin )
        integer SaveUseFF        = Query ( PrintUseFF )

        case Lower(Query(MacroCmdLine))
                when "fontmenuproc"
                        FontMenuProc()
                when "pagemenuproc"
                        PageMenuProc()
        otherwise

                set(Break, _on_ )
                SaveDevice               = Query ( PrintDevice )
                case PageSelection
                  when Booklet
                        InitBooklet()
                        PrintBooklet()
                  when Duplex
                        InitDuplex()
                        PrintDuplex()
                endcase
                ClosePrint()
                AbandonFile()
                EraseDiskFile(TseBookFileName)

                Set ( PrintAddFF ,        SaveAddFF )
                Set ( PrintBotMargin ,    SaveBotMargin )
                Set ( PrintCopies ,       SaveCopies )
                Set ( PrintDevice ,       SaveDevice )
                Set ( PrintFirstPage ,    SaveFirstPage )
                Set ( PrintFooter ,       SaveFooter )
                Set ( PrintHeader ,       SaveHeader )
                Set ( PrintInit ,         SaveInit[60] )
                Set ( PrintLastPage ,     SaveLastPage )
                Set ( PrintLeftMargin ,   SaveLeftMargin )
                Set ( PrintLineNumbers ,  SaveLineNumbers )
                Set ( PrintLineSpacing ,  SaveLineSpacing )
                Set ( PrintLinesPerPage , SaveLinesPerPage )
                Set ( PrintPause ,        SavePause )
                Set ( PrintRightMargin ,  SaveRightMargin )
                Set ( PrintTopMargin ,    SaveTopMargin )
                Set ( PrintUseFF ,        SaveUseFF )
        endcase
end
