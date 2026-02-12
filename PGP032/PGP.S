//*************************************************************************
/************************  Start Comment Area *****************************
//*************************************************************************

                      Tuesday -  October 18, 1994

        ThisFile:  pgp.s   ; TSE interface to PrettyGoodPrivacy
                           ; Original intent was for use with E-mail
                           ; so this macro overwrites the current file
                           ; which originally would have been 'reply.msg'

    As written my choice of a key assignment for this macro is indicated
    in the box below.
                    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    ³<Ctrl s> <e>  SelEncryptMenu()³
                    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Change to anything that you desire on the last few lines of this file.

    ===========================================================================

                             ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
                             ³For TSE 2.00³
                             ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ


  BOILERPLATE:
===========================================================================

  This TSE macro is released to the Public who may use or abuse it as
  they desire.  I would appreciate if you would let me know of any
  problems and of course suggestions for improvements to the macro are
  welcome.

  It does seem to have trouble if multiple files are loaded with
  different PATHS.  The first file in the ring becomes the output for
  PGPs files.

  REQUIREMENTS:
===========================================================================

  PGP (Pretty Good Privacy) whose latest release as of the writing of
  this macro can be found with a filename like 'pgp261.zip'.  Another
  file of use is a 'pgpsh32a.zip' which is a SHELL for PGP and will get
  a new user started.

  You need to setup PGP, generate you own Public Key and then you can
  use this macro to add other peoples Public Keys.  This macro assumes
  that you have PGP up and running correctly.  If you have not used PGP
  then you should try to use it before attempting to jump using this
  macro. Although the macro is not complicated as is uses DOS() calls to
  perform the same action that you would perform from the command line.

  You must have the PGPPATH and Time Parameter in your autoexe.bat or
  set them with a BAT file.  You need something similar to :

  set pgppath=d:\pgp\pgp26       rem  The PATH to my copy of PGP

  rem GMT setup for PGP: New York TZ=est5edt, Chicago TZ=cst6cdt

  SET TZ=est5                    rem  My Time Zone Eastern Time Zone
                                 rem  See PGP DOCS for other zones

  There are a couple of items that you need to change to this macro and
  they can be found by searching for //!//

  The items that require are marked with //!//

  PURPOSE:
===========================================================================

  TSE macro to interface with PGP(Pretty Good Privacy) public key
  encryption program.  The macro was originally designed to encrypt a
  marked block of text from and echo or e-mail reply and leave the
  unmarked portion of the 'reply.msg' intact to supply encrypted
  information to the receiver of the message.

  The macro still will encrypt blocked text but it also performs many
  other functions of PGP like Signing, De-crypting, and other late
  breaking events.

  All selections are set to output encrypted text suitable for echo mail
  or e-mail (i.e.  No control characters, No High-ASCII).

IMPORTANT:
===========================================================================

  User should FIND 'signed_name', 'first_name', and 'last_name' and
  change these variables to suit themselves.  'signed_name' currently
  has my name and initials. Don't make it too much longer than mine
  since the time and date are appended to the message.  The 'first_name'
  and 'last_name' must the name of your PGP user_ID so that you can be
  recognized.

  FIND '//!//' and change all of the  ??????_name variables to suit your
  situation.

---------------------------------------------------------------------------
            Revision History in Reverse Chronological Order:
---------------------------------------------------------------------------

10/18/94:  Remove reference to pre-release and Beta and slight cleanup
0.032      for the second public release. Released to the public.

09/17/94:  General clean up and update for Release 2.00  Added //!// as
           target for searching for items that MUST be changed.
           Removed setup for v2.3a and 2.6

05/26/94:  Path is a problem if not in PATH d:\pgp\pgp26\ for PGP 2.6

02/01/94:  First public release for comment and suggestions
0.03

02/01/94:  Fixed the Signed file bug that was not wrapping a signature
0.02       around the file but was coding the whole file.  The  fix was
           made by using a long command line pgp -sta +clearsig=ON
           <filename>. The PGP file 'config.txt' could also be edited by
           adding CLEARSIG=ON & TEXTMODE=ON to the file and the command
           line could be shortened to pgp -s <filename>  The long
           version is left in this file for users that have not made the
           changes in 'config.txt'............Decrypt() was not
           functioning.  Setup SplitPath to EditFile() the decrypted
           file.  PATHS are occasionally presenting a problem.  Redid
           the SplitPaths in Decrypt() and CleanUp()

01/31/94:  All revisions by Tom Klein.  Added deletion of TEMP files
0.01       added -ea to PGP call to encrypt and put in E-mail format.
           Added Select menu for Encrypt A Block, Signed output, and
           De-encrypt a file or Check the Signature.

01/31/94:  Original idea from Sammy Mitchell that prompted me to get off
           my posterior and fill in the blanks to get the TSE to PGP
           macro started.  It is not overly fancy but sticks to plain
           DOS calls and displays the normal PGP screen and error
           messages.  Message handling was the major problem that keep
           me from making the fancy version.  KISS programming principle
           was used throughout.  -- Tom Klein a.k.a. taky

  *************************************************************************/
//********************** END of Comment Area ******************************

//   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//   ³GLOBAL VARIABLES:³
//   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//  Change the ??????_name strings for you own name or information
//  The time and date are appended to the signed_name so you need to
//  watch the length of the string variable.

//!// Put you PGP user ID in the string items below.

    string first_name[20] = "Tom",
           last_name[20]  = "Klein"

//!// Change item below to anything you want to appear plaintext at the
//    top of encrypted message or change it to a null string if you
//    don't want this information printed.  The time and date is also
//    appended to this string an you might want to remove that also.

    string signed_name[79]="......... from Tom Klein, a.k.a. \\\...tak"

//!// Change item below only if you don't like my choice for temporary
//    files.  The macro deletes the temporary files unless you system
//    happens to crash instead of gracefully exiting the program

    string fn[12] = "!!!!!!!!.$$$"      //Temporary filename

//tak**EncryptBlock  ******************************************************

proc EncryptBlock()

//  PGP Encrypt a block of Text.  A block must be marked

    string  time [5] = ""                    //For use with GetTimeStr()

    if not isBlockMarked()
        Warn("No block to encrypt!..... Please Select a block!!")
        return ()
    endif

    GotoBlockBegin()
    SaveBlock(fn, _OVERWRITE_)

//  EncryptBlock for e-mail TSE 2.00...this allows you encrypt
//  ONLY the marked block if you don't want to encrypt the whole message.

    Dos(" pgp -ea " + fn, _DONT_PROMPT_)
    fn="!!!!!!!!.asc"                       //PGP's output file
    If FileExists(fn)
        BegLine()
        DelBlock()
        CReturn()
        time=GetTimeStr()
        time=substr(time,1,2)+substr(time,4,5)
        InsertText(signed_name + "  " + GetDateStr()+ " @"+ time +" hrs.")
        CReturn()
        CReturn()
        InsertFile(fn)
        GoToBlockEnd()
        UnMarkBlock()
        CReturn()

        fn="!!!!!!!!"                   //Prepare to Delete ALL temp files

        DOS("DEL " + fn + ".*", _DONT_CLEAR_)
        Message("Encryption finished.....")

      else
        Warn("PGP error has occurred....original block left intact")
    endif

end  EncryptBlock

//tak**EncryptFile  *******************************************************

proc EncryptFile()

    string current_filename[40] = "",
           fn[40] = ""

    string  time [5] = ""                    //For use with GetTimeStr()

    fn = CurrFilename()

    current_filename = SplitPath(fn, _drive_ | _path_ | _name_)

    Dos(" pgp -ea " + CurrFilename(), _dont_prompt_)   //Encrypt for e-mail

    fn= current_filename + ".asc"                    //PGP's output file

    If FileExists(fn)

        BegFile()
        MarkStream()
        EndFile()
        MarkStream()
        DelBlock()
        CReturn()
        time=GetTimeStr()
        time=substr(time,1,2)+substr(time,4,5)
        InsertText(signed_name + "  " + GetDateStr()+ " @"+ time +" hrs.")
        CReturn()
        CReturn()
        InsertFile(fn)
        UnMarkBlock()
        CReturn()

        DOS("DEL " + fn + ".asc", _DONT_prompt_)  //Delete TEMP file

        Message("File Encryption finished.....")

      else
        Warn("PGP error has occurred....original file left intact")
    endif

    PopPosition()

end  EncryptFile

//**Encrypt_Sign  ******************************************************
//  Encrypt and SIGN an entire file

proc Encrypt_Sign()

    string current_filename[40] = "",
           fn[40] = ""

    string  time [5] = ""                    //For use with GetTimeStr()

    fn = CurrFilename()

    current_filename = SplitPath(fn, _drive_ | _path_ | _name_)

    Dos(" pgp -esa " + CurrFilename())   //Encrypt for e-mail

    fn= current_filename + ".asc"       //PGP's output file

    If FileExists(fn)

        BegFile()
        MarkStream()
        EndFile()
        MarkStream()
        DelBlock()
        CReturn()
        time=GetTimeStr()
        time=substr(time,1,2)+substr(time,4,5)
        InsertText(signed_name + "  " + GetDateStr()+ " @"+ time +" hrs.")
        CReturn()
        CReturn()
        InsertFile(fn)
        UnMarkBlock()
        BegFile()

        DOS("DEL " + fn + ".asc", _DONT_CLEAR_)  //Delete TEMP file

        Message("File Signed and Encrypted .....")

      else
        Warn("PGP error has occurred....original file left intact")
    endif

end  Encrypt_Sign


//tak** pgpSigned()  ******************************************************

proc  pgpSigned()

//  Output current file as a PGP Signed document [*.asc extension]
//  This procedure produces a Plain Text file wrapped with PGP signature

    string  time [5]                    //For use with GetTimeStr()

    BegFile()
    MarkStream()
    EndFile()
    MarkStream()
    GoToBlockBegin()
    SaveBlock(fn, _OVERWRITE_)
    Dos(" pgp -sta +clearsig=ON " + fn, _DONT_PROMPT_)
    fn="!!!!!!!!.asc"                   //PGPs output file

    If FileExists(fn)                   //Replace file if PGP output OK

       BegLine()
       DelBlock()
       BegFile()
       time=GetTimeStr()
       time=substr(time,1,2)+substr(time,4,5)
       InsertText(signed_name + "  " + GetDateStr()+ " @"+ time+" hrs.")
       CReturn()
       CReturn()
       InsertFile(fn)
       UnMarkBlock()
       BegFile()
       fn="!!!!!!!!"
       DOS("DEL " + fn + ".*", _DONT_CLEAR_)
       Message("Signed file complete...")
       CReturn()

      else
        Warn("PGP error has occurred...ESC will leave file undisturbed")
    endif

end   pgpSigned


//tak**Decrypt  ***********************************************************

proc  Decrypt()

      string current_filename[40] = "",
             fn[40] = ""

//  Determine the current path and filename without the extension since
//  PGP decrypted file is the CurrentFilename without any extension
//  After decrypting the current file TSE displays the un-ecrypted file
//  _on_file_quit_ & _on_exit_called_ will delete the un-ecrypted file
//  and perform other cleanup chores in the CleanUp() procedure


   fn = CurrFilename()

   current_filename = SplitPath(fn, _drive_ | _path_ | _name_)

   Dos(" pgp " + CurrFilename())

   EditFile(current_filename)

   DOS("DEL " + current_filename, _dont_clear_)  //filename w/o _EXT_

end   Decrypt

//tak**GetPublicKey  ******************************************************

proc GetPublicKey()

     DOS(" pgp -ka " + CurrFilename())

end  GetPublicKey


//**InsertPublicKey  ******************************************************

proc InsertPublicKey()

// Insert you PUBLIC key into the current file.
// Your PUBLIC key will be inserted at the cursor location and
// then the temporary key file will be deleted

     string key_path[40] = "",
            fn[40] = ""

    ChDir(SplitPath(CurrFilename(), _drive_ | _path_ ))

    fn = CurrFilename()
    key_path = SplitPath(fn, _drive_ | _path_ )
    key_path = key_path + last_name + ".asc"

DOS(" pgp -kx " + first_name + " " + last_name, _dont_prompt_)  //TSE 2.00
    CReturn()
    InsertFile(key_path)
    GoToBlockEnd()
    UnmarkBlock()
    CReturn()

    dos(" del " + key_path, _dont_prompt_)      //TSE 2.00

end  InsertPublicKey

//**SelEncryptMenu  *******************************************************

menu  SelEncryptMenu()

      Title = "PGP Select 0.032  10/18/94"
      History

      "",,Divide
      "Encrypt Marked &Block"           ,  EncryptBlock()
      "Encrypt Entire &File"            ,  EncryptFile()
      "&Encrypt Entire File and SIGN"   ,  Encrypt_Sign()
      "&SIGN A PlainText Message"       ,  pgpSigned()
      "&Decrypt File or Check Signature"   ,  Decrypt()
      "",,Divide
      "&Obtain Public key from this file"    ,  GetPublicKey()
      "&Insert Your Public Key at Cursor" ,  InsertPublicKey()

end   SelEncryptMenu

//**My choice of a key.  Change to anything that you desire.
//**This is the place to change the key if you desire

<Ctrl s> <e>  SelEncryptMenu()

//*************************************************************************
//        pgp() Links CurrentFile to PGP encryption  10/18/94
//*************************************************************************

