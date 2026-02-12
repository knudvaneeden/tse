/*************************************************************************
Macro Name:  "Keep"
Author: Skip Gore <sg@peganet.com>
Date:  Saturday, August 3, 1996
Overview:
The "Keep" macro is used to transfer information from the database,
dictionary, thes and other files to your current file.

*************************************************************************/

proc Main()
     SaveBlock("c:\temp.txt")
QuitFile()
InsertFile("c:\temp.txt")
EraseDiskFile("c:\temp.txt")
UnmarkBlock()
EndLine()
InsertText(" ")
end

