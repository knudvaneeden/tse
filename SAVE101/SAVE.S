/*
 *        Module : SAVE.S
 *
 *        Author : Edgar Ray Payne, Jr.
 *          Date : 08.21.94
 *     Copyright : (c)1994 by Sirius Software Services  All Rights Reserved.
 *                 (c)1994 by Edgar Ray Payne, Jr.  All Rights Reserved.
 *
 *       Version : 1.01
 *      Modified : 08.21.94  @  22:14:23
 *
 * ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 *ÿÿ
 *  Notes:
 *
 *  Replacement save functions implementing different save schemes
 *ÿÿ
 *ÿÿI use two different types of backup storage, local and global.  Local
 *ÿÿbackups are used mostly for my programming source code.  Since I
 *ÿÿfrequently have modules of the same name for different projects, I don't
 *ÿÿwant the different files mixed.  Local backups are placed in a subdir of
 *ÿÿthe files home location called BAK\.  Global backups are stored in a
 *ÿÿsingle location.  I use D:\BACKUP\.
 *ÿÿ
 *ÿÿAlong with the two types of storage there are three levels of backup;
 *ÿÿblocked, normal and incremental.
 *ÿÿ
 *ÿÿ o Blocked is self-explanatory.  Even with backups turned on files of
 *ÿÿ   this type never get backed-up.  A good example of this type is a
 *ÿÿ   backup file itself.
 *ÿÿ
 *ÿÿ o Normal backups are the same as the default TSE backups except that
 *ÿÿ   they support the backup directory scheme described above.
 *ÿÿ
 *ÿÿ o Incremental backups are a bit different from other backup schemes in
 *ÿÿ   that multiple copies of a file are retained.  Each consecutive backup
 *ÿÿ   is given an incremental number as an extension.  For example the first
 *ÿÿ   time a file is saved, a backup is made with .000 as the extension.
 *ÿÿ   The next save creates .001, the next .002 and so on.  No provision is
 *ÿÿ   made for when .999 is passed, but the backups should be weeded out
 *ÿÿ   long before this happens.
 *ÿÿ
 *ÿÿI use incremental backups for source code where I usually save a file
 *ÿÿevery couple of minutes.  This protects me should a power failure or
 *ÿÿnetwork crash occur, but I might be several saves along before I realize
 *ÿÿI need to go back to a long gone prior version of a file.  With the
 *ÿÿincremental save I just have to scan the backups to find the point I want
 *ÿÿto return to.
 *ÿÿ
 * ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 *ÿÿ
 *ÿÿCredits:
 *ÿÿ
 *ÿÿ Thanks go to Mel Hulse for getting me pointed in the right direction on
 *ÿÿ this.  His response to a message I sent through the echos a while back
 *ÿÿ and subsequent code he sent helped to kick my brain into gear with
 *ÿÿ this problem.  Thanks Mel.
 *ÿÿ
 * ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 *
 *   Modification history:
 *
 *   Date     I     VS    Changes
 * ÄÄÄÄÄÄÄÄ  ÄÄÄÄ  ÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 * 08.21.94  ERPJ  1.00  Initial version.
 * ÄÄÄÄÄÄÄÄ  ÄÄÄÄ  ÄÄÄÄ  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 * 08.21.94  ERPJ  1.01  OOPS.  Typo in last minute changes.  Corrected and
 *                       re-uploaded to SemWare BBS
 *
 */

integer proc mSaveFile()
   //
   //  These two vars control the placement of the local and global backups
   //
   string
      LocalDir[65]  = SplitPath( CurrFilename(), _DRIVE_ | _PATH_ ) + "BAK\",
      GlobalDir[65] = "D:\BACKUP\"

   //
   //  These are the lists of extensions
   //
   //    LocalExt - These files are forced to a local backup
   //    IncExt   - These files get an incremental backup
   //    NoBackUp - These files have backups blocked
   //
   //  All other files are treated as global backups with the default
   //  TSE backup extension.
   //
   string
      LocalExt[65]  = " .s .c .pas .prg .ch .dh .lh .frc .fh " ,
      IncExt[65]    = " .s .c .pas .prg .ch .dh .lh .frc .fh .bat .btm .ini .sys " ,
      NoBackUp[65]  = " .cya .erp .org .bak .tmp .old .new "

   string
      BackUpDir[65] = "",                               // Backup location
      FName[65] = SplitPath( CurrFilename(), _NAME_ ),  // Root name
      TName[65],                                        // Work name
      FExt[4] = Query( BackupExt ),                     // Backup ext to use
      TExt[4] = " " + CurrExt() + " ",                  // Current ext
      savName[65]                                       // Saved file name

   integer
      retVal    = FALSE,                    // Default return value
      DoBackups = Query( MakeBackups ),     // Retrieve backup status
      Ext       = 0,                        // Ext counter
      savBuff,                              // Edit buffer id
      newFile                               // Eork buffer id


   if not DoBackups                         // if backups are disabled
      if IsChanged()                        //  If the file has been changed
         return( SaveFile() )               //   save it and go home
      else
         Message( "No changes pending, save request ignored." )
      endif
   else
      Toggle( MakeBackups )                 // Turn backups off
   endif

   if IsChanged()                           // No backup if file hasn't changed
      //
      //  Check to see if this a local extension
      //
      BackUpDir = iif( Pos( TExt, LocalExt ) <> 0, LocalDir, GlobalDir )

      //
      //  If the backup dir does not exist create it
      //
      if not FileExists( BackUpDir + "*.*" ) and Pos( TExt, NoBackUp ) == 0
         Dos( "MkDir " + BackUpDir, _DONT_CLEAR_ | _DONT_PROMPT_)
      endif

      //
      // Let's see if this is one we want to do an incremental on
      //
      if Pos( TExt, IncExt ) <> 0
         //
         // We'll loop till we find an unused ext
         //
         repeat
            FExt  = Format( Str( Ext ):3:"0" )
            TName = BackUpDir + FName + "." + FExt
            Ext   = Ext + 1
         until not FileExists( TName )

      elseif Pos( TExt, NoBackUp ) <> 0
         //
         //  This ext is flaged for _no_ backups
         //
         TName = ""

      else
         //
         //  We'll just do an ordinary BU
         //
         //  Get the standard BU ext and build the filename
         //
         TName = BackUpDir + FName + FExt

      endif

      //
      //  It's necessary to reload the original from disk to do a proper
      //  backup.  Simply saving the currently loaded file only creates
      //  a duplicate of the edited file, not a copy prior to editing.
      //  All of this is a bit in-elegant but I don't see any other way
      //  to do it.  The one caveat is when you are editing a large file
      //  the reload can take a few seconds in this case.
      //

      //
      // If a temp name has been created and the file already exists
      // on disk (not a new file) then process the backup
      //
      if Length( TName ) and FileExists( CurrFileName() )
         savName = CurrFileName()           // Save the current filename

         savBuff = GetBufferID()            // Save the current buffer
         newFile = CreateTempBuffer()       // Create a work buffer

         GoToBufferID( newFile )            // Go to the work buffer
         InsertFile( savName )              // Load the original file

         SaveAs( TName, _OVERWRITE_ )       // Save the work file w/inc name
                                            // We use SaveAs since normal backup
                                            //   processing is disabled

         AbandonFile( newFile )             // Abandon the work file
         GoToBufferID( savBuff )            // Return to original buffer
      endif

      retVal = SaveFile()                   // Save the original

      if retVal
         Message( "Save successful." )      // Tell user it went OK
      else
         Message( "Save failed.  Return code = " + Str( retVal ))
      endif
   else
      Message( "No changes pending, save request ignored." )
   endif

   //
   //  Turn internal BU processing back on and go home
   //
   Set( MakeBackups, DoBackups )
   return( retVal )
end  mSaveFile


integer proc mSaveAndQuitFile()
   integer retVal

   retVal = mSaveFile()
   AbandonFile()

   return( retVal )
end  mSaveAndQuitFile


integer proc mSaveAllFiles()
   integer
      retVal = FALSE,
      start  = GetBufferID()

   repeat
      if ( Query( BufferType ) == _NORMAL_ )
         retVal = mSaveFile()
      endif

      NextFile()
   until ( GetBufferID() == start )

   return( retVal )
end  mSaveAllFiles


proc mSaveAllAndExit()
   integer
      start  = GetBufferID()

   repeat
      if ( Query( BufferType ) == _NORMAL_ )
         mSaveFile()
      endif

      NextFile()
   until ( GetBufferID() == start )

   AbandonEditor()
end  mSaveAllAndExit


Menu QuitMenu()
   title = "File Changes"

   "&Yes, Save Changes"       ,   mSaveAndQuitFile()
   "&No, Abandon Changes"     ,   AbandonFile()
   "&OOPs, Wrong Key"
end


proc mQuitFile()
   if IsChanged()
      QuitMenu()
   else
      AbandonFile()
   endif
end  mQuitFile



