/***************************************************************************
 This macro creates an incrementing backup file name on file saves instead
 of the standard .BAK so that you can have multiple backup copies.
 If you have a file called TEST.PAS, when you save the file it will make
 a backup called TEST.PA0.  The next will be TEST.PA1 up to TEST.999.

 NOTE FROM ROB HOWSE,  SASKATOON, SK (CAN):

Rather than burn in yet another proc into my UI file, I have chosen instead
to assign the 'main' macro at the end and make the mToggleIncBak proc
PUBLIC.  Then I inserted the INCBAK macro into my "POTPOURRI" list.  Now I
can have Incremental Backups when I want by selecting INCBAK from Potpourri
or I can add INCBAK to my AutoLoad List (ESC M A).  When INCBAK loads, the
public mTOGGLEINCBAK also becomes available, so INCBAK can be toggled ON or
OFF using CTRL X.  I've also added a message indicating INCBAK status on
loading and each time mTOGGLEINCBAK is executed.   --Rbh

 ASSUMPTIONS: This procedure is hooked to the _ON_FILE_SAVE_ in the
              WhenLoaded() procedure as follows:

 ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
 บ proc WhenLoaded()                                             บ
 บ   integer cid = GetBufferId()                                 บ
 บ                                                               บ
 บ   pick_buffer = CreateTempBuffer()                            บ
 บ   GotoBufferId(cid)                                           บ
 บ                                                               บ
 บ   compress_hist = GetFreeHistory()                            บ
 บ   compress_options_history = GetFreeHistory()                 บ
 บ   AddHistoryStr(Query(FindOptions), compress_options_history) บ
 บ                                                               บ
 บ   named_clip_hist = GetFreeHistory()                          บ
 บ                                                               บ
 บ   Hook(_ON_CHANGING_FILES_, OnChangingFiles)                  บ
 บ   Hook(_ON_FIRST_EDIT_, OnFirstEdit)                          บ
 บ                                                               บ
 บ   Hook(_ON_FILE_SAVE_, mIncBak)   //Adds Incrementing Backups บ
 บ end                                                           บ
 ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

 In TSE.CFG, under the System/File Options, you must set MakeBackups
 equal to Off as follows.

 ษอออออออออออออออออออออออออออออป
 บ// System/File Options       บ
 บ                             บ
 บMakeBackups             = Offบ
 ศอออออออออออออออออออออออออออออผ

 If you wish, you can add something to the "Options" menu to indicate the
 incremental backup status.  Here is how I have that menu in my TSE.UI file:

 ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
 บMenu OptionsMenu()                                                                     บ
 บ    history                                                                            บ
 บ                                                                                       บ
 บ    "&AutoIndent"           [MenuStr(AutoIndentMenu,query(AutoIndent)+1) : 6],         บ
 บ                            AutoIndentMenu()            ,   DontClose                  บ
 บ    "&WordWrap"             [OnOffStr(query(WordWrap))   : 3],                         บ
 บ                            Toggle(WordWrap)            ,   DontClose                  บ
 บ    "&Right Margin"         [query(RightMargin) : 5],                                  บ
 บ                            set(RightMargin, ReadNum(Query(RightMargin))),   DontClose บ
 บ    "&Left Margin"          [query(LeftMargin) : 5],                                   บ
 บ                            set(LeftMargin, ReadNum(Query(LeftMargin))),   DontClose   บ
 บ    ""                          ,                   ,   Divide                         บ
 บ    "Tab Ty&pe"             [MenuStr(TabTypeMenu,query(TabType)+1) : 8],               บ
 บ                            TabTypeMenu()               ,   DontClose                  บ
 บ    "&Tab Width"            [query(TabWidth) : 5],                                     บ
 บ                            set(TabWidth, ReadNum(Query(TabWidth))),   DontClose       บ
 บ    ""                          ,                   ,   Divide                         บ
 บ    "&Backups"              [OnOffStr(Query(MakeBackups)) : 3],                        บ
 บ                            Toggle(MakeBackups)         ,   DontClose                  บ
 บ    "&Inc Backups"          [OnOffStr(DoIncBak) : 3],               //Add for Inc Back บ
 บ                            mToggle(DoIncBak),   DontClose          //Add for Inc Back บ
 บ    ""                          ,                   ,   Divide                         บ
 บ    "&Full Configuration  ",          ExecMacro("iconfig"),DontClose                  บ
 บ    "&Save Current Settings  ",       mSaveSettings()                                 บ
 บend                                                                                    บ
 ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

 The last thing to do is to include this file, "INCBAK.S" into your TSE.UI
 or where ever you put your custom macros so that it is burned into TSE.

 Your files will now be saved with incrementing file extensions.

 You can toggle making the incremental backups via the menu as seen above,
 or assign mToggle(DoIncBak) to a key.

 ************************************************
 PARAMETERS:  None

 RETURNS:     TRUE or FALSE

 GLOBAL VARS: DoIncBak - indicates whether incrementing backup should be made

 LOCAL VARS:  fn  - local string to hold file path and name
              ext - local string to hold file extension
              c   - local integer to create incrementing backup name

 CREATED:         15-APR-93  v1.0 Tom Kellen

 MODIFICATIONS:   28-SEP-94  TAK  v2.0    Updated to use internal functions in
                                          TSE v2.0

                  11-OCT-94  TAK  v2.1    Optimized and simplified code.
                                          It now makes backup versions to
                                          .999 and will give a warning if
                                          it is unable to make a backup
                                          file.

***************************************************************************/
// This is a Global Variable indicating whether backups should be made
integer DoIncBak = true

PUBLIC proc mToggleIncBak()
        DoIncBak = NOT DoIncBak
        if DoIncBak == TRUE   Message("Incremental Backups ON")
    elseif DoIncBak == FALSE  Message("Incremental Backups OFF")
    endif
end

/**************************************************************************
  This macro is called when saving a file instead of Save() to create
  self incrementing backup file names.
 **************************************************************************/

integer proc mIncBak()
    string fn[80] = SplitPath(CurrFileName(), _DRIVE_ | _NAME_)
    string ext[4] = SplitPath(CurrFileName(), _EXT_)
    integer c

    if not DoIncBak         // If this isn't set, don't make a backup
        return (false)
    endif

    if ext == ''            // If the file name doesn't have an extension,
        ext = '.'           // then add a dot to the ext variable.
    endif
    ext = substr(format(ext:-4:"0"), 1, 3)  // Pad the extension with 0's

    c = 0

    repeat
        case c
            when 10                        // Shorten the ext variable by 1 to
                ext = substr (ext, 1, 2)   // handle double digit versions.
            when 100                       // Shorten the ext variable by 1 to
                ext = substr (ext, 1, 1)   // handle triple digit versions.
        endcase
        if not FileExists (fn + ext + Str (c))
            RenameDiskFile (CurrFileName(), fn + ext + Str (c))
            return (true)
        else
            c = c + 1
        endif
    until c > 999

    alarm()
    warn('Unable to create backup file ' + fn + ext + Str (c))

    return (false)
end mIncBak

proc Main()
    Hook(_ON_FILE_SAVE_, mIncBak)
        if DoIncBak == TRUE   Message("Incremental Backups ON")
    elseif DoIncBak == FALSE  Message("Incremental Backups OFF")
    endif
end


