//  stub macro for explorer context menu
//  purpose: print file

string LargeFont[] = "E&k2G(10U(s0p12.00h10.0v0s0b3T&l1s0o6D&a6l87M"
string SmallFont[] = "E&k2G(10U(s0p16.67h8.5v0s0b0T&l1s0o5C&a8l121M"

menu PrintMenu()
    title = "Printer Setup"

    "&Large Font"
    "&Small Font"
    "",, divide
    "&Abort Print"
end

proc PrintLarge()
    Set(PrintLeftMargin,0)
    Set(PrintRightMargin,82)
    Set(PrintTopMargin,2)
    Set(PrintBotMargin,0)
    Set(PrintLinesPerPage,61)
    Set(PrintHeader,"FDP")
    Set(PrintFooter,"")
    Set(PrintInit,LargeFont)
    PrintFile()
end

proc PrintSmall()
    Set(PrintLeftMargin,0)
    Set(PrintRightMargin,114)
    Set(PrintTopMargin,2)
    Set(PrintBotMargin,0)
    Set(PrintLinesPerPage,99)
    Set(PrintHeader,"FDP")
    Set(PrintFooter,"")
    Set(PrintInit,SmallFont)
    PrintFile()
end

proc main()
    string fn[_MAXPATH_] = CurrFilename()

    if ChDir(SplitPath(fn,_DRIVE_|_PATH_))
        LogDrive(fn[1])
    endif
    PrintMenu()
    case MenuOption()
        when 1  PrintLarge()
        when 2  PrintSmall()
    endcase
    Exit()
end
