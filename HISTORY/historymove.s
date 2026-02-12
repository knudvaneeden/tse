// jigbubhist.s - bubble a history item to the top or delete the item

<ctrlshift x> execmacro("jigbubhist")

/*** jigbubhist.s
The purpose of this macro is to allow moving any item on any history
list to the top of the list, or to delete any item from any history
list.

When executed, this macro will offer a list of the standard TSE
histories to choose from.

Once chosen, a prompt allows you to enter an item in the history to move
or delete. That prompt supports the chosen history and you can access it
by using the cursordown key.

Once an item has been selected, another prompt allows you to choose to
move the item to the top of the list or to delete the item from the
history list. The default action is to move the item to the top of the
history list.

If nothing else, it is a convenient way to take a look at some of the
more obscure history lists. :)

If you have suggestions or discover any problems, BE SURE to mention it.

***/

// list startup
proc ListStartup()

Unhook(ListStartup)
ListFooter("Select a History and Press Enter, or Press ESC to Quit.")

end

proc main()

integer tb=0

string xs[255]=""    // first prompt
string xs2[1]="M"    // second prompt
string cr[1]=chr(13)

integer i=0
integer hl=0 // line number of history chosen from list

// get the history names and the TSE variable numbers
setglobalint("hvar1",_EDIT_HISTORY_) setglobalstr("hname1","_EDIT_HISTORY_")
setglobalint("hvar2",_NEWNAME_HISTORY_) setglobalstr("hname2","_NEWNAME_HISTORY_")
setglobalint("hvar3",_EXECMACRO_HISTORY_) setglobalstr("hname3","_EXECMACRO_HISTORY_")
setglobalint("hvar4",_LOADMACRO_HISTORY_) setglobalstr("hname4","_LOADMACRO_HISTORY_")
setglobalint("hvar5",_KEYMACRO_HISTORY_) setglobalstr("hname5","_KEYMACRO_HISTORY_")
setglobalint("hvar6",_GOTOLINE_HISTORY_) setglobalstr("hname6","_GOTOLINE_HISTORY_")
setglobalint("hvar7",_GOTOCOLUMN_HISTORY_) setglobalstr("hname7","_GOTOCOLUMN_HISTORY_")
setglobalint("hvar8",_REPEATCMD_HISTORY_) setglobalstr("hname8","_REPEATCMD_HISTORY_")
setglobalint("hvar9",_DOS_HISTORY_) setglobalstr("hname9","_DOS_HISTORY_")
setglobalint("hvar10",_FINDOPTIONS_HISTORY_) setglobalstr("hname10","_FINDOPTIONS_HISTORY_")
setglobalint("hvar11",_REPLACEOPTIONS_HISTORY_) setglobalstr("hname11","_REPLACEOPTIONS_HISTORY_")
setglobalint("hvar12",_FIND_HISTORY_) setglobalstr("hname12","_FIND_HISTORY_")
setglobalint("hvar13",_REPLACE_HISTORY_) setglobalstr("hname13","_REPLACE_HISTORY_")
setglobalint("hvar14",_FILLBLOCK_HISTORY_) setglobalstr("hname14","_FILLBLOCK_HISTORY_")

// load the history names to temporary buffer
tb=createtempbuffer()
for i=1 to 14
addline(getglobalstr("hname"+str(i)))
endfor
begfile()

// display the list of history names
Hook(_LIST_STARTUP_, ListStartup)
List("Listing History Names", Query(windowCols)/2)

// handle selection, if one
if query(key) in <enter>,<leftbtn>
hl=currline()
sound(9000,90)
else
sound(50,50)
warn("Cancelled 1")
goto ending
endif

// prompt for item to move or delete
if ask(getglobalstr("hname"+str(hl))+
      " Item to move or delete,CursorDown=History,ESC=Quit",
      xs,getglobalint("hvar"+str(hl))) and length(xs)
addhistorystr(xs,getglobalint("hvar"+str(hl))) // default push to top
else
sound(50,50)
warn("Cancelled")
goto ending
endif

// prompt to delete or leave at top
if ask("(M)ove Item to top,(D)elete Item from list",xs2) and length(xs2)==1
if lower(xs2)=="d"
  delhistorystr(getglobalint("hvar"+str(hl)),1)
  sound(7000,70)
  warn("Item"+cr+cr+xs+cr+cr+"deleted from the"+cr+cr+
        getglobalstr("hname"+str(hl))+cr+cr+" history list.")
else
  sound(9000,90)
  warn("Item"+cr+cr+xs+cr+cr+"moved to top of the"+cr+cr+
        getglobalstr("hname"+str(hl))+cr+cr+" history list.")
endif
else
sound(50,50)
warn("Cancelled")
goto ending
endif

goto ending
ending:

if tb // close the temporary buffer
abandonfile(tb)
endif

for i=1 to 14 // clear the global variables
delglobalvar("hvar"+str(i))
delglobalvar("hname"+str(i))
endfor

end
