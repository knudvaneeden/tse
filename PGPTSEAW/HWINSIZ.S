// HWINSIZ.S  opens two horizontal windows, the 2nd one is 2/3rds of the screen
//    Syntax:  tse file1 file2 /ehwinsiz

proc main()
        UpdateDisplay()
        HWindow()
        ResizeWindow(_UP_,4)
end

