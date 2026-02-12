/*
Program....: qfproj.s
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 06/02/93  11:09 am  Last Modified: 08/30/95 @ 07:58 am
Notice.....: Copyright 1993 COB System Designs, Inc., All Rights Reserved.
QFRestore..: Ø1,1Æ
Compiler...: TSE 2.5
Abstract...:
Changes....:
€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
€ This program is a part of a series of macros written by COB System Designs€
€ for TSE/*Base users...these are not public domain but are for sale at a   €
€ reasonable price of $69.00. Please support the work involved in writing   €
€ these programs.                                                           €
€ For sales information and technical support, call SEMWARE Corporation:    €
€                                                                           €
€ MAIL: SemWare Corporation               FAX: (770) 640-6213               €
€       730 Elk Cove Court                                                  €
€       Kennesaw, GA  30152-4047  USA                                       €
€                                         InterNet: sales@semware.com       €
€                                                   qf.support@semware.com  €
€ PHONE (SALES ONLY): (800) 467-3692      OTHER VOICE CALLS: (770) 641-9002 €
€          Inside USA, 9am-5pm ET                              9am-5pm ET   €
€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€
*/

#include ["QFOption.inc"]
#include ["QFPath.inc"]
#include ["QFRestor.Inc"]
#include ["QFMsg.Inc"]

forward proc QFProject()
forward proc QFProjClose(integer nCloseType)


CONSTANT PRJ_ONLY  = 1
CONSTANT PRJ_FILES = 2


menu QFProjMenu()
   Title = "Quiet Flight Project"
   X = 10
   Y = 3
   "&Open Project"          , QFProject(), CloseAllBefore
   "",,Divide
   "&Close Project"         , QFProjClose(PRJ_ONLY), CloseAllBefore
   "&Close Project w/&Files", QFProjClose(PRJ_FILES), CloseAllBefore

end QFProjMenu




menu YesNoOnly()  // no cancel
       "&Yes"
       "&No"
end YesNoOnly


// Close project only OR project & associated files
proc QFProjClose(integer nCloseType)
   integer nID, nLastID, nProjID
   integer lProjMember, lBackup
   string fn[100], cDefaultDir[80]

   PushPosition()
   PushBlock()

   nProjID = GetGlobalInt("nProjID")
   if GotoBufferID(nProjID)
      if FileChanged()
         lBackup = Set(MakeBackups, FALSE)   // don't make a backup file
         SaveFile()
         Set(MakeBackups, lBackup)
      endif

      // Close all project files which are loaded
      if nCloseType == PRJ_FILES
         BegFile()
         repeat
            UnMarkBlock()
            MarkLine()

            // Skip "[DIR=]" directives in the project file
            if lFind("^\[DIR=\c", "ilgx")
               cDefaultDir = GetText(CurrCol(),80)
               cDefaultDir = SplitPath(ExpandPath(substr(cDefaultDir, 1, pos("]", cDefaultDir)-1)),
                                       _DRIVE_ | _PATH_)
            else
               fn = ltrim(GetText(1, 100))
               if length(fn)
                  fn = ExpandPath(cDefaultDir + GetText(1, 100))
                  if GotoBufferID(GetBufferID(fn))
                     if FileChanged()
                        UpdateDisplay()
                     endif // FileChanged()
                     QuitFile()
                  endif // GotoBufferID(GetBufferID(fn))
               endif
            endif // lFind("^\[DIR=\c", "ilgx")
            GotoBufferID(nProjID)

         until not down()

      endif
      AbandonFile()
      message("Quiet Flight Project closed")
   else
      message("Project not open")
   endif

   SetGlobalInt("nProjId", 0)
   PopBlock()
   PopPosition()

end QFProjClose



// Loads all the files specified in the passed project (.PRJ) file
proc QFLoadProj(string cProjFile)
   string cFile[80], cDefaultDir[50] = ""
   string cProjName[80], cProjDir[50]
//   string cFirstFile[50]=""

// Commented out 08/05/93 at 11:25 pm
//   string cLoadFiles[254]=""

   integer nLoadCnt = 0, nMsgLevel, lCreate = FALSE, lOkay, nError

   nMsgLevel = Set(MsgLevel, _NONE_)

   PushBlock()
   PushPosition()

   cProjName = cProjFile
   if not length(cProjName) or not length(SplitPath(cProjName, _NAME_))
      cProjName = cProjName + "*.prj"
   endif

   if not length(SplitPath(cProjName, _DRIVE_ | _PATH_))
      cProjDir = QFGetOption("GENERAL", "ProjectDir", nError)
      if not FileExists(cProjDir + "*.*")
         QFMessage("Project directory in QF.CFG is invalid", 3, TRUE)
         cProjDir = ""
      endif
      cProjName = splitpath(cProjDir, _DRIVE_ | _PATH_) + cProjName
   endif

   if Pos("*", cProjName) or Pos("?", cProjName)
      if FileExists(cProjName)
         cProjName = PickFile(cProjName)
      else
         message("No project files found in " + SplitPath(cProjName, _DRIVE_ | _PATH_))
         cProjName = ""
      endif
   endif

   if length(cProjName) and SplitPath(cProjName, _EXT_) == ""
      cProjName = cProjName + ".prj"
      upper(cProjName)
   endif

   // Make sure the project exists before continuing
   if length(cProjName) and not FileExists(cProjName)
      if YesNoOnly("Project " + cProjName + " not found.  Create?") == 1
         lCreate = TRUE
         if GotoBufferID(GetBufferID(cProjName)) or CreateBuffer(cProjName, _SYSTEM_)
            AddLine("QF Project: " + SplitPath(cProjName, _NAME_))
            AddLine("[DIR=" + SplitPath(ExpandPath(cProjName), _DRIVE_ | _PATH_)+"]")
            AddLine()
            ScrollToRow(3)
         endif
      else
         cProjName = ""
      endif
   endif

   lOkay = TRUE

   if length(cProjName) and GotoBufferID(GetBufferID(cProjName))
      if BufferType() <> _SYSTEM_
         BufferType( _SYSTEM_)
      endif
   else
      lOkay = FALSE
   endif


   if not lOkay
      lOkay = CreateBuffer(cProjName, _SYSTEM_) and InsertFile(cProjName)
   endif // GotoBufferID(GetBufferID(cProjName))


   if lOkay
      // Set a global variable containing the name of current project
      SetGlobalInt("nProjID", GetBufferID())

      BegFile()
      if lFind("QF Project", "ig")
         down()
      endif

      // Process each line in the project file
      nLoadCnt = 0
      repeat
         UnMarkBlock()
         MarkLine()


         // Set a default directory if "[DIR=]" specified in project
         if lFind("^\[DIR=\c", "ilgx")
            cDefaultDir = GetText(CurrCol(),80)
            cDefaultDir = SplitPath(ExpandPath(substr(cDefaultDir, 1, pos("]", cDefaultDir)-1)),
                                 _DRIVE_ | _PATH_)
         else
            cFile = ltrim(GetText(1, 80))


            // if a path is not hardcoded to this filename, then
            // append the default path
            if not length(SplitPath(cFile, _DRIVE_ | _PATH_))
               cFile = cDefaultDir + cFile
            endif

            // Make sure we don't try to load a project file from
            // within a project--could lead to a recursion problem!!
            // Also, assume filenames prefixed with ';' are project
            // comments
            if not EquiStr(SplitPath(cFile, _EXT_), CurrExt())
               and substr(cFile, 1, 1) <> ";" and length(SplitPath(cFile, _NAME_ | _EXT_))
               if FileExists(cFile)
                  PushPosition()
                  if EditFile(cFile)
                     QFRestore()
                     nLoadCnt = nLoadCnt + 1
                  endif
                     // Build the string for the editfile list
                     // if the length of the string exceeds the Length
                     // of the string, then we need to purge it by loading
                     // some of the files and then re-initialize the editfile
                     // list with the current file name to be loaded.


                  PopPosition()
               else

                  // if a file is not found, ask if it should be removed
                  if YesNoOnly(cFile + " not found.  Remove from project?") == 1
                     delLine()
                  endif // YesNoOnly(cFile + " not found.  Remove from project?")
               endif // FileExists(cFile)

            endif // SplitPath(cFile, _EXT_) <> SplitPath(CurrFileName(), _EXT_)
         endif // lFind("^\[DIR=\c", "ilgx")

      until not down()

// Commented out 08/05/93 at 11:23 pm
//      if Length(cLoadFiles)
//         EditFile(cLoadFiles)
//         cLoadFiles=""
//      endif // Length(cLoadFiles)

      if not lCreate
         if nLoadCnt > 0
            message(format(nLoadCnt) + " files loaded from project")
         else
            QFMessage(SplitPath(cProjName, _NAME_ | _EXT_) + " is an empty project file", 3, FALSE)
         endif
         // Save the project file if it has changed
         if FileChanged()
            SaveFile()
         endif
      else
         QFMessage("Project " + cProjName + " created", 3, FALSE)
      endif // not lCreate
   endif // lOkay

   PopPosition()


   // If they loaded the project from the command line, we
   // may have an extraneous file of the same name but in
   // a different directory loaded.  Close it if this is so.
   if BufferType() <> _SYSTEM_ and pos(".prj", CurrFileName())
      AbandonFile()
   endif

   if BufferType() == _SYSTEM_
      NextFile()
   endif

// Commented out 08/06/93 at 08:15 am
//   if Length(cFirstFile)
//      EditFile(cFirstFile)
//   endif // Length(cFirstFile)

   PopBlock()
   Set(MsgLevel, nMsgLevel)

end QFLoadProj


// Requests a project file to load
proc QFProject()
   string cProjFile[80] = "*.prj"

   // Request name of project file to load
   if CurrExt() <> ".prj"
      if ask("Project to load/create [.PRJ]:", cProjFile, _EDIT_HISTORY_)
         QFLoadProj(cProjFile)
      endif
   else
      QFLoadProj(SplitPath(CurrFileName(), _NAME_ | _EXT_))
   endif

end QFProject



proc main()
   string cProjTitle[40] = "Quiet Flight Project"

   if pos(".prj" , CurrFileName()) == 0

      // Retrieve the name of the current project, if there is one
      PushPosition()
      if GotoBufferID(GetGlobalInt("nProjID"))
         cProjTitle = "QF Project: " + SplitPath(CurrFileName(), _NAME_)
      endif
      PopPosition()

      QFProjMenu(cProjTitle)
   else
      QFProject()
      if NumFiles() == 0
         GotoBufferID(GetGlobalInt("nProjID"))
         BufferType( _NORMAL_)
         EndFile()
         SetGlobalInt("nProjID", 0)
      endif
   endif
end main



