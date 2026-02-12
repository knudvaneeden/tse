
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
string  src_filename[60]          // Pathname of the source file.
integer src_wnd_id                // Window Id of source file.

string cmd_line[160]              // Dos command line buffer.

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

        cmd_line = Format (comp,
                           comp_opts,
                           src_filename,
                           err_directive + err_file)

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

        cmd_line = Format (comp,
                           comp_opts,
                           src_filename,
                           err_directive + err_file)

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

        cmd_line = Format (comp,
                           comp_opts,
                           src_filename,
                           err_directive + err_file)

      otherwise

        Warn ('"' + ext + '" ' + "Type files not yet supported.")
        return (0)

    endcase

    return (1)
end

proc mGetNxtErr ()

    integer err_lin   = 0
    integer err_col   = 0

    string ans[1]     = "Y"

    GotoWindow (err_wnd_id)
    GotoMark ("p")

    if (lFind (err_srch_pat, "x"))

        if (lFind (err_ln_pat, "x"))

            GotoColumn (CurrCol () + err_ln_pos)

            PushBlock ()
            MarkWord ()

            err_lin = Val (GetMarkedText ())

            Warn (Str (err_lin))
            PopBlock ()

            if (err_col_pat <> "")

              if (lFind (err_col_pat, "x"))

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

    else

      if (Ask ("No more errors found. Remove Error File? [Y,n] ", ans) and
          (Length (ans) > 0))

          AbandonFile (GetBufferId (ExpandPath (err_file)))
          if (FileExists (err_file))

              EraseDiskFile (err_file)

          endif

          CloseWindow()

      endif

    endif
end

menu LoadExecMac ()

    "&Load macro"
    "&Execute macro"

end

proc mOnSuccess (string ext)

    string fn[60] = ""

    case (ext)

      when ".s"

          if (src_filename == "$temp$.s")

              Warn ("Compile Succeeded, but compiled file is called $temp$.mac")

          endif

          fn = SplitPath (src_filename, _DRIVE_ | _NAME_)

          case LoadExecMac ("Compile successful")

              when 1

                  LoadMacro (fn)

              when 2

                  ExecMacro (fn)

          endcase

      when ".c", ".h"

          Warn ("Compile Succeeded!")

      when ".cpp", ".hpp"

      otherwise

    endcase

end

proc mCompile ()

    integer temp_flg  = 0

    string cur_ext[4] = (SplitPath (CurrFilename (), _EXT_))

    src_wnd_id   = WindowId ()
    src_filename = CurrFilename ()

    if (mCConfigfor (cur_ext))

        OneWindow ()

        if (isChanged ())

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

        Dos (cmd_line, _DONT_CLEAR_)

        if (temp_flg)

            EraseDiskFile (src_filename)

        endif

        if (FileExists (err_file))

            HWindow ()
            EditFile (err_file)

            err_wnd_id = WindowId ()
            PlaceMark ("p")

            if (lFind (err_srch_pat, "x"))

                mGetNxtErr ()

            else

                AbandonFile ()
                EraseDiskFile (err_file)
                CloseWindow ()
                mOnSuccess (cur_ext)

            endif

        else

          Warn ("Error " + '"'  + cmd_line + '" ' + "didn't work!")

        endif

    endif

end


<Ctrl F5> mCompile ()
<Ctrl F6> mGetNxtErr ()
