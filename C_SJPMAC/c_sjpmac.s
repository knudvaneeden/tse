// Ayant trouve la macro de compilation C_MAC U/L par Lynn Lively
// tr‚s utile pour C et TP, j'ai voulu l'adapter pour la compilation
// de programmes ecrits avec QuickBasic.
// Il reste un probleme, que je ne sais pas resoudre :
// Comment se positionner sur la bonne ligne, quand l'erreur
// concerne un 'END IF' ou autre commande seul sur sa ligne.
// Le compilateur ne donnant pas le Nø des lignes dans ses
// messages d'erreurs, ma macro pour QB se positionne … la
// premiŠre occurence du mot d‚sign‚ par le message d'erreur.
//
// Si vous trouvez une solution, ou ameliorez cette macro (ce qui
// ne sera pas difficile, car je debute avec TSE), merci de me le
// faire savoir.
//      ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·
//      ³  par FAX, en FRANCE : 033-59.06.13.47                º
//      ³  ou … mon adresse : Serge ALSUNARD                   º
//      ³                     Villa "Maranatha !"              º
//      ³                     10, boulevard Sainte Madeleine   º
//      ³                     64200 - BIARRITZ, (FRANCE)       º
//      ÔÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
//

string   comp[30]                 // Pathname of compiler.
string   comp_opts[60]            // Compile options.
string   err_directive[10]        // Command Line syntax for outputing errors
                                  // to a file.
string   err_file[30]             // Pathname to error file.
                                  // pattern.
integer  err_wnd_id               // Error Window ID.
string   err_srch_pat[60]         // Reg Expression to find error/warning line.
string   err_ln_pat[60]           // Reg Expression Pattern to find error
                                  // Line Numbers in error file.
integer  err_ln_pos               // Add or subrtact from position found from
                                  // pattern.
string   err_col_pat[60]          // Reg Expression to find error Column.
integer  err_col_pos              // Add or subrtact from position found from
                                  // pattern.
string   src_filename[60]         // Pathname of the source file.
integer  src_wnd_id               // Window Id of source file.
string   cmd_line[160]            // Dos command line buffer.

string   err_srch_txt[80]         // Reg Expression for error text to find.
string   cur_ext[4]               // Extension du Fichier
integer  err_lin
integer  err_col
string   ans[1]

integer proc mCConfigFor (string ext)
    case (ext)
      when ".s"
        comp          = "sc "
        comp_opts     = ""
        err_directive = " > "
        err_file      = "$error$.tmp"
        err_srch_pat  = "^{Error}|{Warning} #[0-9]# #\c"
        err_ln_pat    = "([0-9]*,"
        err_ln_pos    = 1
        err_col_pat   = ",[0-9]*)"
        err_col_pos   = 1
        cmd_line      = Format (comp,comp_opts,src_filename,err_directive + err_file)

      when ".qb", ".qba", ".qb2", ".qbx"
        comp          = "QB "
        comp_opts     = " /D /E /F /S /LFSFS.EXE; "
        err_directive = " > "
        err_file      = "$error$.tmp"
        err_srch_pat  = "^ "
        err_ln_pat    = ""           //([0-9]*,"
        err_ln_pos    = 0
        err_col_pat   = ""           //",[0-9]*)"
        err_col_pos   = 0
        cmd_line      = Format (comp,src_filename,comp_opts,err_directive + err_file)

      when ".c", ".h"
        comp          = "tcc "
        comp_opts     = " -c "
        err_directive = " > "
        err_file      = "$error$.tmp"
        err_srch_pat  = "^{Error}|{Warning} .* [0-9]*:"
        err_ln_pat    = "[0-9]*:"
        err_ln_pos    = 0
        err_col_pat   = ""
        err_col_pos   = 0
        cmd_line      = Format (comp,comp_opts,src_filename,err_directive + err_file)

      when ".cpp", ".hpp"
        comp          = "tcc "
        comp_opts     = " -c "
        err_directive = " > "
        err_file      = "$error$.tmp"
        err_srch_pat  = "^{Error}|{Warning} .* [0-9]*:"
        err_ln_pat    = "[0-9]*:"
        err_ln_pos    = 0
        err_col_pat   = ""
        err_col_pos   = 0
        cmd_line      = Format (comp,comp_opts,src_filename,err_directive + err_file)

      otherwise
        Warn ('"' + ext + '" ' + "Ce Type de fichier n'est pas support‚.")
        return (0)
    endcase
    return (1)
end

menu LoadExecMac ()
    "&Load macro"
    "&Execute macro"
end

Proc mBoucleMFErreurQbasic()
    EndLine()
    JoinLine()
end

Proc mRepereLigneErreurQbasic()
    Repeat
        UnmarkBlock()
        Up()
        Begline()
        Markline()
    Until (Not lFind(err_srch_pat, "LI"))
    err_srch_txt = GetMarkedText()
    UnmarkBlock()
end

Proc mMiseEnFormeErreurQbasic()
    EditFile(err_file)
    err_wnd_id = WindowId()
    if (lFind(err_srch_pat, "GI"))
        PlaceMark("p")
        mBoucleMFErreurQbasic()
    endif
    While (lRepeatFind())
        mBoucleMFErreurQbasic()
    EndWhile
    saveFile()
    BegFile()
end

proc mNextErreurQbasic()
    err_col = CurrCol()
    EndLine()
    PlaceMark("p")
    mRepereLigneErreurQbasic()
    GotoMark("p")
    Markline()
    Markline()
    Begline()
    lFind(err_srch_pat, "i")
    If CurrCol() > 50
        err_col_pos = 30
        GotoColumn(CurrCol()+30)
        GotoColumn(CurrCol()-30)
    Endif
    GotoWindow(src_wnd_id)
    if (lFind(err_srch_txt, "gi"))
        GotoColumn(err_col+30)
        GotoColumn(err_col)
    endif
end

Proc mNextErreurNonQB()
    if (lFind (err_ln_pat, "i"))
        GotoColumn (CurrCol () + err_ln_pos)
        PushBlock ()
        MarkWord ()
        err_lin = Val (GetMarkedText ())
        Warn (Str (err_lin))
        PopBlock ()
        if (err_col_pat <> "")
           if (lFind (err_col_pat, "i"))
                GotoColumn (CurrCol () + err_col_pos)
                PushBlock ()
                MarkWord ()
                err_col = Val (GetMarkedText ())
                PopBlock ()
           endif
        endif
    endif
    EndLine ()
    PlaceMark ("p")
    BegLine ()

    GotoWindow (src_wnd_id)
    if (err_lin > 0)
        GotoLine (err_lin)
        if (err_col > 0)
            GotoColumn (err_col)
        endif
    endif
end

proc mGetNxtErr()
    err_lin   = 0
    err_col   = 0
    ans       = "Y"

    UnmarkBlock()
    GotoWindow (err_wnd_id)
    GotoMark ("p")
    if (lFind (err_srch_pat, "I"))
        case (cur_ext)
            when ".qb", ".qbx", ".qb1", ".qb2"
                mNextErreurQbasic()
            otherwise
                mNextErreurNonQB()
        endcase
    else
      if (Ask ("Plus d'erreurs. Fichier des Erreurs … d‚truire ? [Y,n] ", ans) and
          (Length (ans) > 0))
          AbandonFile (GetBufferId (ExpandPath (err_file)))
          if (FileExists (err_file))
              EraseDiskFile (err_file)
          endif
          UnmarkBlock()
          CloseWindow()
      endif
    endif
end

proc mGetPrevErr()
    err_lin   = 0
    err_col   = 0
    ans       = "Y"

    UnmarkBlock()
    GotoWindow (err_wnd_id)
    BegLine()
    PlaceMark("p")
    lFind (err_srch_pat, "BI")
    BegLine()
    PlaceMark("p")
    mGetNxtErr()
end

proc mGetThisErr()
    err_lin   = 0
    err_col   = 0
    ans       = "Y"

    UnmarkBlock()
    GotoWindow (err_wnd_id)
    BegLine()
    PlaceMark("p")
    mGetNxtErr()
end

proc mOnSuccess (string ext)
    string fn[60] = ""
    case (ext)
      when ".s"
          if (src_filename == "$temp$.s")
              Warn ("Compilation valide, Mais Fichier Compil‚ renomm‚ $temp$.mac")
          endif
          fn = SplitPath (src_filename, _DRIVE_ | _NAME_)
          case LoadExecMac ("Compilation valide")
              when 1
                  LoadMacro (fn)
              when 2
                  ExecMacro (fn)
          endcase
      when ".c", ".h"
          Warn ("Compilation valide")
      when ".cpp", ".hpp"
      otherwise
          Warn ("Compilation valide")
    endcase
end

proc mCompile()
    integer temp_flg  = 0
    Cur_ext      = (SplitPath (CurrFilename(), _EXT_))
    src_wnd_id   = WindowId()
    src_filename = CurrFilename()
    if (mCConfigfor (cur_ext))
        OneWindow()
        // if (isChanged())
        if (FileChanged())
            //
            // If it has been changed save it as a temporary file
            // before compiling and re configure the command line.
            //
            src_filename = "$temp$" + cur_ext
            SaveAs (src_filename, _OVERWRITE_)
            mCConfigfor (cur_ext)
            temp_flg = 1
        endif
        AbandonFile (GetBufferId (ExpandPath (err_file)))
        if (FileExists (err_file))
            EraseDiskFile (err_file)
        endif
        case (cur_ext)
          when ".qb", ".qbx", ".qb1", ".qb2"
             Dos(cmd_line)
          otherwise
             Dos(cmd_line, _DONT_CLEAR_)
        endcase
        if (temp_flg)
            EraseDiskFile (src_filename)
        endif
        if (FileExists (err_file))
            HWindow()
            case (cur_ext)
              when ".qb", ".qbx", ".qb1", ".qb2"
                  mMiseEnFormeErreurQbasic()
              otherwise
                  EditFile(err_file)
                  err_wnd_id = WindowId()
                  PlaceMark("p")
            endcase
            if (lFind (err_srch_pat, "GI"))
                mGetNxtErr()
            else
                AbandonFile()
                EraseDiskFile(err_file)
                CloseWindow()
                mOnSuccess(cur_ext)
            endif
        else
            Warn ("Erreur " + '"'  + cmd_line + '" ' + "ne marche pas !")
        endif
    endif
end

<Ctrl F9>  mCompile()
<Ctrl F10> mGetNxtErr()
<Ctrl F11> mGetThisErr()
<Ctrl F12> mGetPrevErr()
