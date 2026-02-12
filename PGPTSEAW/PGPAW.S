
// IMPORTANT: Search for '//!//' and customize as necessary!
//*************************************************************************
/************************  Start Comment Area *****************************
//*************************************************************************
                           10/26/95 16:46:11
  This File:  PGPAW.S  :  TSE Pro interface to PrettyGoodPrivacy (PGP)
          Cobbled together by Anthony Williams, CIS 76655,1552
                     Based on PGPxxx.S by Tom Klein
                 Tested with TSE ver. 2.50, PGP 2.62(i)

    As written my choice of a key assignment for this macro is indicated
    in the box below.  Change it at end of file, if desired.
                    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    ³<Ctrlalt p>   SelEncryptMenu()³
                    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

===========================================================================
                             ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
                             ³For TSE 2.50³
                             ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
  BOILERPLATE:
===========================================================================

This TSE macro is released to the Public who may use or abuse it as they
desire.  I would appreciate if you would let me know of any problems and
of course suggestions for improvements to the macro are welcome.  I can
be reached on the SemWare BBS or via CIS email.

  REQUIREMENTS:
===========================================================================
TSE Pro, ver. 2.50.  [Line 382, MakeTempName() won't compile under 2.00].

PGP (Pretty Good Privacy) whose latest release as of the writing of this
macro can be found with a filename like 'pgp262.zip' or 'pgp262i.zip'.

You need to set up PGP, generate your own Public Key, and then you can
use this macro to add other peoples Public Keys.  This macro assumes
that you have PGP up and running correctly.  If you have not used PGP
then you should try to use it before attempting to jump using this
macro. The macro is not complicated as is uses DOS() calls to perform
the same action that you would perform from the command line. You *must*
have the PGPPATH and TZ Time Parameter environmental variables, usually
set in your autoexec.bat or with a batch file. You need something
similar to :

set PGPPATH=E:\PGP26           rem  The PATH to your copy of PGP
SET TZ=MST7                    rem  AZ never changes time

                 Other zones:  TZ=EST5EDT
                               TZ=CST6CDT
                               TZ=MST7MDT
                               TZ=PST8PDT

There are a couple of items that you need to change in this macro and
they can be found by searching for //!//.

PURPOSE:
===========================================================================

TSE macro to interface with PGP(Pretty Good Privacy) public key
encryption program.  The macro was originally designed to encrypt a
marked block of text from and echo or e-mail reply and leave the
unmarked portion of the 'reply.msg' intact to supply encrypted
information to the receiver of the message.  It integrates well with
Compuserve navigators like Tapcis and Ozcis, as well as QWK packet
readers like OLX and KWQ/2.

The macro will encrypt and decrypt text as well as signing plaintext,
inserting your public key in a message, and adding to your public key
ring a public key you receive in a message.  All encryption selections
are set to output encrypted "armored" text suitable for echo mail or
e-mail (i.e.  No control characters, No High-ASCII).

IMPORTANT:
===========================================================================

User should FIND 'last_name' and 'mykey_id' and change these variables
to suit themselves.  'signed_name' currently has my name and initials.
Don't make it too much longer than mine since the time and date are
appended to the message.  The 'last_name' should be the name of your PGP
user_ID so that your key can be recognized.  FIND '//!//' and change all
of the variables to suit your situation.

---------------------------------------------------------------------------
Revision History in Reverse Chronological Order:
---------------------------------------------------------------------------

    10/12/95:  Cosmetic changes

    8/11/95 :  Extensive changes by afw cited below.  My priority
    was insuring I could never lose my input, even if PGP failed for
    lack of correct pass phrase or for another reason.  In all cases,
    the user should be able to recover his original Plaintext (PT) or
    Ciphertext (CT) and try again.  The PT of outgoing messages is
    saved in a *.INP file.  However, if PGP is successful, CT input is
    deleted and PT substituted.

    [Note: if you want your outgoing messages to remain on your
    disk as CT, you can add the following line to your CONFIG.TXT, the
    option file used and required by PGP.  This will ensure that you
    can decrypt your outgoing message, if you wish.

         # Make every encrypted message also readable by sender.
         EncryptToSelf=ON

    Without this line, only your correspondent will be able
    to read your message.]

    If security of the computer is in question, this macro should
    be redesigned to avoid saving any plaintext.  In addition,
    there is some question about swap files.  If possible, use a
    ram disk.  This macro should be adequate for those without
    these concerns.

    I designed this macro for use with OzCIS, which supplies PT
    headers and footers.  The macro is designed to preserve them
    when replying to a CT message.  It will substitute PT for CT
    of the input message, and then allow encrypting your reply
    without damaging the header or tearline.  To insure this
    operation, I have required block marking in the Decrypt
    and PgpSigned procedures.  If you always deal with a file
    without headers or footers, you can eliminate this requirement.
    I now use it with Tapcis v.6 as well as KWQ/2.

    As written, the output has the same name as the input, but
    the original CT is changed to PT, in the case of Decryption, or
    vice versa for Encryption.  Any header or footer present is
    preserved.

    Major changes by afw:
          ş make InsertKey() work even with multiple partitions
          ş *always* preserve input file even with PGP error
          ş allow specification of a specific secret key
          ş new procs EncryptSgnBlock() & EncryptSgnFile()
          ş insist on block for Decrypt() to avoid losing PT header
          ş preserve PT header and footer, if any, when decrypting
          ş new hotkey and reminder message()
          ş make signing default when encrypting
          ş corrected Dos("DEL"...)
          ş corrected a PGP command
          ş allow use of specific drive for temp files
          ş rearranged menu

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

     01/31/94:  Original macro by Tom Klein from a outline suggested by
     10/18/94   Sammy Mitchell to interface TSE to PGP.

//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

  *************************************************************************
  ********************** END of Comment Area ******************************
     ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     ³GLOBAL VARIABLES:³
     ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Change the last_name and mykey_id strings for your own name and key ID.
    The time and date are appended to the signed_name so you need to
    watch the length of the string variable.

*** Put your PGP public key ID in the string items below.     *************/
                                //!//
    string last_name[8] = "Williams", //only for pub key file: last_name.ASC
           mykey_id[10] = "0x96C771B5"  //preface your ID with "0x"
                // -- prevents getting wrong key if your SECRING.PGP has
                //   several different keys with same name

/***  Change drive as necessary [Q:\ is a ramdisk on my system]:  ****/

            string stmp[40] = "Q:\"                 //location for temp files
              string fn[16] = "Q:\!!!!!!!!.$$$"     //Temp file for Encrypt
/***
      Change item below to anything you want to appear plaintext at the
      top of encrypted message or change it to a null string if you
      don't want this information printed.  The time and date is also
      appended to this string an you might want to remove that also.
***/
                            //!//
//  string signed_name[79]="......... from Tom Klein, a.k.a. \\\...tak"
    string signed_name[79]="... Anthony Williams, Landscape Aesthete"
//*******************************************************************
      string CurrFileNameNoExt[40] = ""             //don't change
//*******************************************************************

proc EncryptSgnBlock()
    string  time [5] = ""                    //For use with GetTimeStr()
    string  fnn[40] = ""
    fnn = CurrFilename()
    CurrFileNameNoExt = SplitPath(fnn, _drive_ | _path_ | _name_)
    if not isBlockMarked()
        Warn("No block to encrypt!..... Please Select a block!!")
        return ()
    endif
    GotoBlockBegin()
    SaveBlock(fn, _OVERWRITE_)
      Dos(" pgp -esa " + fn , _DEFAULT_)
    fn = SplitPath(fn, _drive_ | _path_ | _name_) + ".ASC"
    If FileExists(fn)
        SaveAs(Format(CurrFileNameNoExt+".INP"))     //afw//
        BegLine()
        DelBlock()
        CReturn()
        time=GetTimeStr()
        time=substr(time,1,2)+substr(time,4,5)
        InsertText(signed_name + "  " + GetDateStr()+ " at "+ time +" MST")
        CReturn()                                                   //!//
        CReturn()
        InsertFile(fn)
        GoToBlockEnd()
        UnMarkBlock()
        CReturn()
            fn = SplitPath(fn, _drive_ | _path_ | _name_)
        DOS("DEL " + fn + ".*", _DONT_PROMPT_)
    else
        Warn("PGP error has occurred....original block left intact--1")
        DOS("DEL " + stmp + "!!!!!!!!.$$$", _DONT_PROMPT_)
    endif
end EncryptSgnBlock

//*******************************************************************
// Encrypt but don't sign a block

proc EncryptBlock()
    string  time [5] = ""                    //For use with GetTimeStr()
    string  fnn[40] = ""
    fnn = CurrFilename()
    CurrFileNameNoExt = SplitPath(fnn, _drive_ | _path_ | _name_)
    if not isBlockMarked()
        Warn("No block to encrypt!..... Please Select a block!!")
        return ()
    endif
    GotoBlockBegin()
    SaveBlock(fn, _OVERWRITE_)
      Dos(" pgp -ea " + fn , _DEFAULT_)
    fn = SplitPath(fn, _drive_ | _path_ | _name_) + ".ASC"
    If FileExists(fn)
        SaveAs(Format(CurrFileNameNoExt+".INP"))     //afw!//
        BegLine()
        DelBlock()
        CReturn()
        time=GetTimeStr()
        time=substr(time,1,2)+substr(time,4,5)
        InsertText(signed_name + "  " + GetDateStr()+ " at "+ time +" MST")
        CReturn()                                                   //!//
        CReturn()
        InsertFile(fn)
        GoToBlockEnd()
        UnMarkBlock()
        CReturn()
            fn = SplitPath(fn, _drive_ | _path_ | _name_)
        DOS("DEL " + fn + ".*", _DONT_PROMPT_)   //Prepare to Delete all temp files
    else
        Warn("PGP error has occurred....original block left intact--2")
        DOS("DEL " + stmp + "!!!!!!!!.$$$", _DONT_PROMPT_)
    endif
end  EncryptBlock

//*******************************************************************
//Encrypt but don't sign a file

proc EncryptFile()
    string fn[40] = ""
    string fnesf[40] = ""
    string  time [5] = ""                    //For use with GetTimeStr()
    fn = CurrFilename()
    CurrFileNameNoExt = SplitPath(fn, _drive_ | _path_ | _name_)
    fnesf = stmp + SplitPath(fn, _name_)
    SaveAs(fnesf)
    Dos(" pgp -ea " + fnesf)   //Encrypt for e-mail
    fn = SplitPath(fnesf, _drive_ | _path_ | _name_) + ".ASC"
    If FileExists(fn)
        SaveAs(Format(CurrFileNameNoExt+".INP"))    //afw!//
        BegFile()
        MarkStream()
        EndFile()
        MarkStream()
        DelBlock()
        CReturn()
        time=GetTimeStr()
        time=substr(time,1,2)+substr(time,4,5)
        InsertText(signed_name + "  " + GetDateStr()+ " at "+ time +" MST")
        CReturn()                                                    //!//
        CReturn()
        InsertFile(fn)
        UnMarkBlock()
        BegFile()
        DOS("DEL " + SplitPath(fn, _drive_ | _path_ | _name_) + ".*", _DONT_PROMPT_)
    else
        Warn("PGP error has occurred....original file left intact--3")
        DOS("DEL " + SplitPath(fn, _drive_ | _path_ | _name_) + ".*", _DONT_PROMPT_)
    endif
end  EncryptFile

//*******************************************************************
//  Encrypt and SIGN an entire file

proc EncryptSgnFile()
    string fn[40] = ""
    string fnesf[40] = ""
    string  time [5] = ""                    //For use with GetTimeStr()
    fn = CurrFilename()
    CurrFileNameNoExt = SplitPath(fn, _drive_ | _path_ | _name_)
    fnesf = stmp + SplitPath(fn, _name_)
    SaveAs(fnesf)
    Dos(" pgp -esa " + fnesf)   //Encrypt for e-mail
    fn = SplitPath(fnesf, _drive_ | _path_ | _name_) + ".ASC"
    If FileExists(fn)
        SaveAs(Format(CurrFileNameNoExt+".INP"))     //afw!//
        BegFile()
        MarkStream()
        EndFile()
        MarkStream()
        DelBlock()
        CReturn()
        time=GetTimeStr()
        time=substr(time,1,2)+substr(time,4,5)
        InsertText(signed_name + "  " + GetDateStr()+ " at "+ time +" MST")
        CReturn()                                                     //!//
        CReturn()
        InsertFile(fn)
        UnMarkBlock()
        BegFile()
        DOS("DEL " + SplitPath(fn, _drive_ | _path_ | _name_) + ".*", _DONT_PROMPT_)
                //delete TEMP files
    else
        Warn("PGP error has occurred....original file left intact--4")
        DOS("DEL " + SplitPath(fn, _drive_ | _path_ | _name_) + ".*", _DONT_PROMPT_)
    endif
end  EncryptSgnFile

//*******************************************************************
//  Output current file as a PGP Signed document [original filename]
//  This procedure produces a Plain Text file wrapped with PGP signature

proc  pgpSigned()
    string  time [5]                    //For use with GetTimeStr()
    if not isBlockMarked()
        Warn("No block to sign!..... Please Select a block!!")
        return ()
    endif
/*** disabled to require use of block
    BegFile()
    MarkStream()
    EndFile()
    MarkStream()
***/
    GoToBlockBegin()
    PushPosition()
    SaveBlock(fn, _OVERWRITE_)
    Dos(" pgp -sta +clearsig=ON " + fn, _DEFAULT_)
    fn="!!!!!!!!.asc"                   //PGPs output file
    If FileExists(fn)                   //Replace file if PGP output OK
       BegLine()
       DelBlock()
       PopPosition()
       time=GetTimeStr()
       time=substr(time,1,2)+substr(time,4,5)
       InsertText(signed_name + "  " + GetDateStr()+ " at "+ time+" MST")
       CReturn()                                                    //!//
       CReturn()
       InsertFile(fn)
       UnMarkBlock()
       BegFile()
       fn="!!!!!!!!"
       DOS("DEL " + fn + ".*", _DONT_PROMPT_)
       CReturn()
    else
        Warn("PGP error has occurred...ESC will leave file undisturbed--5")
    endif
end   pgpSigned

//*******************************************************************
// Decrypt a block (block required)

proc  Decrypt()
      string fnn[40] = ""
    string fnblk[40] = ""
    if not isBlockMarked()
        Warn("No BLOCK to decrypt!..... Please Select a block!!")
        return ()
    endif
    fnblk = MakeTempName(stmp, ".P!P")  //!// requires TSE ver. 2.50
//!// alternate for TSE ver. 2.0://  fnblk = "Q:\!!PGPAW!.P!P"
    GotoBlockBegin()
    PushPosition()
    SaveBlock(fnblk ,_OVERWRITE_)
    KillBlock()
    fnn = CurrFilename()
    CurrFileNameNoExt = SplitPath(fnn, _drive_ | _path_ | _name_)
    Dos(" pgp " + CurrFilename())
    if FileExists(CurrFileNameNoExt)
        EditFile(CurrFileNameNoExt)
        PopPosition()
        InsertFile(CurrFileNameNoExt)
        DOS("DEL " + CurrFileNameNoExt, _DONT_PROMPT_)  //filename w/o _EXT_
        DOS("DEL " + fnblk , _DONT_PROMPT_)               //.P!P
    else
        Warn("PGP error has occurred....original file left intact--6")
        InsertFile(fnblk)
    endif
end Decrypt

//*******************************************************************
// Add a public key the file to your keyring

proc GetPublicKey()
     DOS(" pgp -ka " + CurrFilename())
end  GetPublicKey

//*******************************************************************
/* Insert your PUBLIC key into the current file.
   Your PUBLIC key will be inserted at the cursor location and
   then the temporary key file will be deleted                     */

proc InsertPublicKey()
    string key_path[40] = "",
                 fn[40] = ""
    LogDrive(SplitPath(CurrFilename(), _drive_ ))
    ChDir(SplitPath(CurrFilename(), _drive_ | _path_ ))
    fn = CurrFilename()
    key_path = SplitPath(fn, _drive_ | _path_ )
    key_path = key_path + last_name + ".asc"
    DOS(" pgp -kxa " + mykey_id + " " + last_name, _DONT_PROMPT_)
    CReturn()
    InsertFile(key_path)
    GoToBlockEnd()
    UnmarkBlock()
    CReturn()
    dos(" del " + key_path, _DONT_PROMPT_)
end  InsertPublicKey

//*******************************************************************

menu  SelEncryptMenu()
      Title = "PGPaw: PGP Select Macro 26Oct95"
      History
      "",,Divide
      "Encrypt and SIGN Marked &Block"  ,  EncryptSgnBlock()
      "Encrypt and SIGN Entire &File"   ,  EncryptSgnFile()
        "",,Divide
      "Encrypt Marked B&lock"           ,  EncryptBlock()
      "Encrypt &Entire File"            ,  EncryptFile()
        "",,Divide
      "&SIGN A PlainText Message"       ,  pgpSigned()
        "",,Divide
      "&Decrypt File or Check Signature"   ,  Decrypt()
      "",,Divide
      "&Obtain Public key from this file"    ,  GetPublicKey()
      "&Insert Your Public Key at Cursor" ,  InsertPublicKey()
end   SelEncryptMenu

//*******************************************************************
// change key assignment as desired  //!//
<ctrlalt p>  SelEncryptMenu()

proc main()
    Message ("PGP Macro hotkey is Ctrl-Alt-P")      //!//
end
//*******************************************************************

